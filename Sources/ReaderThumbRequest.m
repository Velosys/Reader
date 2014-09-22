//
//	ReaderThumbRequest.m
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

#import "ReaderThumbRequest.h"
#import "ReaderThumbView.h"
#import "ReaderDocument.h"

@implementation ReaderThumbRequest
{
    ReaderDocument *_document;
    
	NSString *_cacheKey;

	NSString *_thumbName;

	ReaderThumbView *_thumbView;

	NSUInteger _targetTag;

	NSInteger _thumbPage;

	CGSize _thumbSize;

	CGFloat _scale;
}

#pragma mark - Properties

@synthesize document = _document;
@synthesize thumbView = _thumbView;
@synthesize thumbPage = _thumbPage;
@synthesize thumbSize = _thumbSize;
@synthesize thumbName = _thumbName;
@synthesize targetTag = _targetTag;
@synthesize cacheKey = _cacheKey;
@synthesize scale = _scale;

#pragma mark - ReaderThumbRequest class methods

+ (instancetype)newForView:(ReaderThumbView *)view document:(ReaderDocument *)document page:(NSInteger)page size:(CGSize)size
{
	return [[ReaderThumbRequest alloc] initForView:view document:document page:page size:size];
}

#pragma mark - ReaderThumbRequest instance methods

- (instancetype)initForView:(ReaderThumbView *)view document:(ReaderDocument *)document page:(NSInteger)page size:(CGSize)size
{
	if ((self = [super init])) // Initialize object
	{
		NSInteger w = size.width; NSInteger h = size.height;

		_thumbView = view; _thumbPage = page; _thumbSize = size;

		_document = document;

		_thumbName = [[NSString alloc] initWithFormat:@"%07i-%04ix%04i", (int)page, (int)w, (int)h];

		_cacheKey = [[NSString alloc] initWithFormat:@"%@+%@", _thumbName, document.guid];

		_targetTag = [_cacheKey hash]; _thumbView.targetTag = _targetTag;

		_scale = [[UIScreen mainScreen] scale]; // Thumb screen scale
	}

	return self;
}

@end
