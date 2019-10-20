#import <Cocoa/Cocoa.h>
#import <CoreFoundation/CoreFoundation.h>
#import <CoreServices/CoreServices.h>
#import <Foundation/Foundation.h>
#import <QuickLook/QuickLook.h>

OSStatus GeneratePreviewForURL(void *thisInterface, QLPreviewRequestRef preview, CFURLRef url,
                               CFStringRef contentTypeUTI, CFDictionaryRef options);
void CancelPreviewGeneration(void *thisInterface, QLPreviewRequestRef preview);

/* -----------------------------------------------------------------------------
   Generate a preview for file
   This function's job is to create preview for designated file
   -----------------------------------------------------------------------------
 */
OSStatus GeneratePreviewForURL(void *thisInterface, QLPreviewRequestRef preview, CFURLRef url,
                               CFStringRef contentTypeUTI, CFDictionaryRef options) {
  NSString *domainName = @"com.sub.QLAddict";

  /*
   * Use NSUserDefaults for theme switch
   */
  NSDictionary *defaults = [[NSUserDefaults standardUserDefaults] persistentDomainForName:domainName];
  NSString *styleName = [[defaults valueForKey:@"theme"] lowercaseString];

  if (styleName == nil || [styleName isEqual:@"default"]) {
    styleName = @"addic7ed";
  }

  /*
   * Import stylesheets
   */
  NSBundle *thisBundle = [NSBundle bundleWithIdentifier:domainName];

  NSString *base = [thisBundle pathForResource:@"base" ofType:@"css"];
  NSString *theme = [thisBundle pathForResource:styleName ofType:@"css" inDirectory:@"themes"];

  NSString *baseStyle = [[NSString alloc] initWithContentsOfFile:base encoding:NSUTF8StringEncoding error:nil];
  NSString *themeStyle = [[NSString alloc] initWithContentsOfFile:theme encoding:NSUTF8StringEncoding error:nil];

  /*
   * Get content from giving url
   */
  NSString *content = [NSString stringWithContentsOfURL:(__bridge NSURL *)url encoding:NSUTF8StringEncoding error:nil];

  /*
   * Find encoding type
   */
  NSPipe *pipe = [NSPipe pipe];
  NSFileHandle *file = pipe.fileHandleForReading;

  NSTask *task = [[NSTask alloc] init];
  task.launchPath = @"/usr/bin/file";
  task.arguments = @[ @"--mime-encoding", @"-b", (__bridge NSURL *)url ];
  task.standardOutput = pipe;

  [task launch];

  NSData *data = [file readDataToEndOfFile];
  [file closeFile];

  NSString *encodingType = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] uppercaseString];

  // Allow all encoding types
  if (content == nil) {
    // If not UTF-8
    content = [NSString stringWithContentsOfURL:(__bridge NSURL *)url encoding:0 error:nil];
  }

  /*
   * Detect line endings
   */
  NSString *lineEndingType = @"";

  if ([content rangeOfString:@"\r\n" options:NSRegularExpressionSearch].location != NSNotFound) {
    lineEndingType = @"CRLF";
  } else if ([content rangeOfString:@"\r" options:NSRegularExpressionSearch].location != NSNotFound) {
    lineEndingType = @"CR";
  } else if ([content rangeOfString:@"\n" options:NSRegularExpressionSearch].location != NSNotFound) {
    lineEndingType = @"LF";
  }
  // Use unix line endings
  content = [content stringByReplacingOccurrencesOfString:@"\r(\n)?"
                                               withString:@"\n"
                                                  options:NSCaseInsensitiveSearch | NSRegularExpressionSearch
                                                    range:NSMakeRange(0, [content length])];

  /*
   * Wrap subtitle sequence
   */
  NSString *sequencePattern = @"(\\d+)\n([\\d:,]+)\\s+-{2}>\\s+([\\d:,]+)\n([\\s\\S]*?(?=(\n){2}|$))";
  NSRegularExpression *sequencesRegex =
      [NSRegularExpression regularExpressionWithPattern:sequencePattern
                                                options:NSRegularExpressionCaseInsensitive
                                                  error:nil];
  // Put sequence in table
  NSString *outputContent = [sequencesRegex stringByReplacingMatchesInString:content
                                                                     options:0
                                                                       range:NSMakeRange(0, [content length])
                                                                withTemplate:@"<tr>"
                                                                              "<td class=\"id\">"
                                                                              "$1"
                                                                              "</td>"
                                                                              "<td class=\"time\">"
                                                                              "$2 --> $3"
                                                                              "</td>"
                                                                              "<td class=\"sub\">"
                                                                              "$4"
                                                                              "</td>"
                                                                              "</tr>"];

  /*
   * Count the sequences matched
   */
  NSUInteger numberOfSequence = [[outputContent componentsSeparatedByString:@"<tr>"] count] - 1;

  // Test if regular srt file
  if (numberOfSequence <= 0) {
    return qErr;
  }

  /*
   * Finding html tags
   */
  NSString *noTagStatus = @"";

  if ([content rangeOfString:@"<[A-Za-z0-9]*\\b[^>]*>" options:NSRegularExpressionSearch].location == NSNotFound) {
    noTagStatus = @"<span class=\"green\">YES</span>";
  } else {
    noTagStatus = @"<span class=\"red\">NO</span>";
  }

  /*
   * Get title and link
   */
  MDItemRef item = MDItemCreateWithURL(kCFAllocatorDefault, url);
  NSArray *whereFroms = CFBridgingRelease(MDItemCopyAttribute(item, kMDItemWhereFroms));

  NSString *titleContent = @"";
  if (whereFroms) {
    // If is downloaded
    NSString *subtitleLink = [whereFroms lastObject];

    if ([subtitleLink containsString:@"http://www.addic7ed.com/serie/"]) {
      // If downloaded from addic7ed.com and is a serie
      NSArray *splitedLink = [subtitleLink componentsSeparatedByString:@"/"];

      NSString *serieTitle =
          [[splitedLink[4] stringByReplacingOccurrencesOfString:@"_" withString:@" "] stringByRemovingPercentEncoding];
      NSInteger seasonNumber = [splitedLink[5] intValue];
      NSInteger episodeNumber = [splitedLink[6] intValue];
      NSString *episodeTitle =
          [[splitedLink[7] stringByReplacingOccurrencesOfString:@"_" withString:@" "] stringByRemovingPercentEncoding];

      titleContent = [NSString stringWithFormat:@"<h1>"
                                                 "<a href=\"%@\">"
                                                 "%@ S%02tdE%02td - %@"
                                                 "</a>"
                                                 "</h1>",
                                                subtitleLink, serieTitle, seasonNumber, episodeNumber, episodeTitle];
    } else if ([subtitleLink containsString:@"http://www.addic7ed.com/movie/"]) {
      // If downloaded from addic7ed.com and is a movie
      titleContent = [NSString stringWithFormat:@"<h1>"
                                                 "<a href=\"%@\">"
                                                 "Link to movie"
                                                 "</a>"
                                                 "</h1>",
                                                subtitleLink];
    }
  }

  /*
   * First time of first sequence and last time of last sequence
   */
  NSRange searchedRange = NSMakeRange(0, [content length]);
  NSRange lastMatchGroup2 = NSMakeRange(0, 12);

  NSRegularExpression *regex =
      [NSRegularExpression regularExpressionWithPattern:@"\n([\\d:,]+)\\s+-{2}>\\s+([\\d:,]+)\n" options:0 error:nil];
  NSTextCheckingResult *match = [regex firstMatchInString:content options:0 range:searchedRange];
  NSString *firstTime = [content substringWithRange:[match rangeAtIndex:1]];

  NSArray *matches = [regex matchesInString:content options:0 range:searchedRange];
  for (NSTextCheckingResult *match in matches) {
    lastMatchGroup2 = [match rangeAtIndex:2];
  }
  NSString *lastTime = [content substringWithRange:lastMatchGroup2];

  /*
   * Preview
   */
  NSString *infoBar = [NSString stringWithFormat:@"%@\n"
                                                  "<ul class=\"infoBar\">\n"
                                                  "<li><b>%tu</b> sequences</li>\n"
                                                  "<li>NoTAG : <b>%@</b></li>"
                                                  "<li><small>%@ | %@</small></li>"
                                                  "</ul>\n"
                                                  "<ul class=\"infoBar right\">\n"
                                                  "<li>%@</li>"
                                                  "<li>%@</li>"
                                                  "</ul>\n",
                                                 titleContent, numberOfSequence, noTagStatus, firstTime, lastTime,
                                                 encodingType, lineEndingType];

  NSString *html = [NSString stringWithFormat:@"<!DOCTYPE html>\n"
                                               "<html>\n"
                                               "<head>\n"
                                               "<meta charset=\"utf-8\">\n"
                                               "<style type=\"text/css\">\n%@</style>\n"
                                               "<style type=\"text/css\">\n%@</style>\n"
                                               "<base href=\"%@\"/>\n"
                                               "</head>\n"
                                               "<body>\n"
                                               "%@"
                                               "<table>\n"
                                               "%@"
                                               "</table>\n"
                                               "</body>\n"
                                               "</html>",
                                              baseStyle, themeStyle, url, infoBar, outputContent];

  CFDictionaryRef previewProperties = (__bridge CFDictionaryRef) @{
    (__bridge NSString *)kQLPreviewPropertyTextEncodingNameKey : @"UTF-8",
    (__bridge NSString *)kQLPreviewPropertyMIMETypeKey : @"text/html",
  };

  QLPreviewRequestSetDataRepresentation(preview, (__bridge CFDataRef)[html dataUsingEncoding:NSUTF8StringEncoding],
                                        kUTTypeHTML, previewProperties);

  return noErr;
}

void CancelPreviewGeneration(void *thisInterface, QLPreviewRequestRef preview) {
  // Implement only if supported
}
