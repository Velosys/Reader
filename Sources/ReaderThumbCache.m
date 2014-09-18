//
//	ReaderThumbCache.m
//	Reader v2.8.0
//
//	Created by Julius Oklamcak on 2011-09-01.
//	Copyright © 2011-2014 Julius Oklamcak. All rights reserved.
//
//	Permission is hereby granted, free of charge, to any person obtaining a copy
//	of this software and associated documentation files (the "Software"), to deal
//	in the Software without restriction, including without limitation the rights to
//	use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
//	of the Software, and to permit persons to whom the Software is furnished to
//	do so, subject to the following conditions:
//
//	The above copyright notice and this permission notice shall be included in all
//	copies or substantial portions of the Software.
//
//	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
//	OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//	WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
//	CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import "ReaderThumbCache.h"
#import "ReaderThumbQueue.h"
#import "ReaderThumbFetch.h"
#import "ReaderThumbView.h"
#import "ReaderDocument.h"

@implementation ReaderThumbCache
{
	NSCache *thumbCache;
}

#pragma mark - Constants

#define CACHE_SIZE 2097152

#pragma mark - ReaderThumbCache class methods

+ (ReaderThumbCache *)sharedInstance
{
	static dispatch_once_t predicate = 0;

	static ReaderThumbCache *object = nil; // Object

	dispatch_once(&predicate, ^{ object = [self new]; });

	return object; // ReaderThumbCache singleton
}

+ (NSString *)thumbCachePathForDocument:(ReaderDocument *)document
{
    NSString *cachesPath = document.cachePath;

	return [cachesPath stringByAppendingPathComponent:document.guid]; // Append GUID
}

+ (void)createThumbCacheForDocument:(ReaderDocument *)document
{
	NSFileManager *fileManager = [NSFileManager new]; // File manager instance

	NSString *cachePath = [ReaderThumbCache thumbCachePathForDocument:document]; // Thumb cache path

	[fileManager createDirectoryAtPath:cachePath withIntermediateDirectories:NO attributes:nil error:NULL];
}

+ (void)removeThumbCacheForDocument:(ReaderDocument *)document
{
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0),
	^{
		NSFileManager *fileManager = [NSFileManager new]; // File manager instance

		NSString *cachePath = [ReaderThumbCache thumbCachePathForDocument:document]; // Thumb cache path

		[fileManager removeItemAtPath:cachePath error:NULL]; // Remove thumb cache directory
	});
}

+ (void)touchThumbCacheForDocument:(ReaderDocument *)document
{
	NSFileManager *fileManager = [NSFileManager new]; // File manager instance

	NSString *cachePath = [ReaderThumbCache thumbCachePathForDocument:document]; // Thumb cache path

	NSDictionary *attributes = [NSDictionary dictionaryWithObject:[NSDate date] forKey:NSFileModificationDate];

	[fileManager setAttributes:attributes ofItemAtPath:cachePath error:NULL]; // New modification date
}

#pragma mark - ReaderThumbCache instance methods

- (instancetype)init
{
	if ((self = [super init])) // Initialize
	{
		thumbCache = [NSCache new]; // Cache

		[thumbCache setName:@"ReaderThumbCache"];

		[thumbCache setTotalCostLimit:CACHE_SIZE];
	}

	return self;
}

- (id)thumbRequest:(ReaderThumbRequest *)request priority:(BOOL)priority
{
	@synchronized(thumbCache) // Mutex lock
	{
		id object = [thumbCache objectForKey:request.cacheKey];

		if (object == nil) // Thumb object does not yet exist in the cache
		{
			object = [NSNull null]; // Return an NSNull thumb placeholder object

			[thumbCache setObject:object forKey:request.cacheKey cost:2]; // Cache the placeholder object

			ReaderThumbFetch *thumbFetch = [[ReaderThumbFetch alloc] initWithRequest:request]; // Create a thumb fetch operation

			[thumbFetch setQueuePriority:(priority ? NSOperationQueuePriorityNormal : NSOperationQueuePriorityLow)]; // Queue priority

			request.thumbView.operation = thumbFetch; [thumbFetch setThreadPriority:(priority ? 0.55 : 0.35)]; // Thread priority

			[[ReaderThumbQueue sharedInstance] addLoadOperation:thumbFetch]; // Queue the operation
		}

		return object; // NSNull or UIImage
	}
}

- (void)setObject:(UIImage *)image forKey:(NSString *)key
{
	@synchronized(thumbCache) // Mutex lock
	{
		NSUInteger bytes = (image.size.width * image.size.height * 4.0f);

		[thumbCache setObject:image forKey:key cost:bytes]; // Cache image
	}
}

- (void)removeObjectForKey:(NSString *)key
{
	@synchronized(thumbCache) // Mutex lock
	{
		[thumbCache removeObjectForKey:key];
	}
}

- (void)removeNullForKey:(NSString *)key
{
	@synchronized(thumbCache) // Mutex lock
	{
		id object = [thumbCache objectForKey:key];

		if ([object isMemberOfClass:[NSNull class]])
		{
			[thumbCache removeObjectForKey:key];
		}
	}
}

- (void)removeAllObjects
{
	@synchronized(thumbCache) // Mutex lock
	{
		[thumbCache removeAllObjects];
	}
}

@end
