#include <CoreFoundation/CoreFoundation.h>
#include <CoreServices/CoreServices.h>
#include <QuickLook/QuickLook.h>

#import <Cocoa/Cocoa.h>

OSStatus GeneratePreviewForURL(void *thisInterface, QLPreviewRequestRef preview,
                               CFURLRef url, CFStringRef contentTypeUTI,
                               CFDictionaryRef options);
void CancelPreviewGeneration(void *thisInterface, QLPreviewRequestRef preview);

/* -----------------------------------------------------------------------------
   Generate a preview for file

   This function's job is to create preview for designated file
   ----------------------------------------------------------------------------- */

OSStatus GeneratePreviewForURL(void *thisInterface, QLPreviewRequestRef preview,
                               CFURLRef url, CFStringRef contentTypeUTI,
                               CFDictionaryRef options)
{
    NSString *domainName = @"com.sub.QLAddict";

    // Use NSUserDefaults for theme switch
    NSDictionary *defaults = [[NSUserDefaults standardUserDefaults] persistentDomainForName:domainName];
    NSString     *styleName = [defaults valueForKey:@"theme"];

    if (styleName == nil || [styleName.lowercaseString isEqual:@"default"]) {
        styleName = @"addic7ed";
    }

    // Import stylesheets
    NSBundle *thisBundle = [NSBundle bundleWithIdentifier:domainName];

    NSString *base = [thisBundle pathForResource:@"base"
                                          ofType:@"css"];
    NSString *theme = [thisBundle pathForResource:styleName
                                           ofType:@"css"
                                      inDirectory:@"themes"];

    NSString *baseStyle = [[NSString alloc] initWithContentsOfFile:base
                                                          encoding:NSUTF8StringEncoding
                                                             error:nil];
    NSString *themeStyle = [[NSString alloc] initWithContentsOfFile:theme
                                                           encoding:NSUTF8StringEncoding
                                                              error:nil];

    // Get content from giving url
    NSString *content = [NSString stringWithContentsOfURL:(__bridge NSURL *)url
                                                 encoding:NSUTF8StringEncoding
                                                    error:nil];

    if (content == nil) {
        content = [NSString stringWithContentsOfURL:(__bridge NSURL *)url
                                           encoding:0
                                              error:nil];
    }

    content = [content stringByReplacingOccurrencesOfString:@"\r\n"
                                                 withString:@"\n"
                                                    options:NSLiteralSearch
                                                      range:NSMakeRange(0, [content length])];

    // Get title and link
    MDItemRef item = MDItemCreateWithURL(kCFAllocatorDefault, url);
    NSArray   *whereFroms = CFBridgingRelease(MDItemCopyAttribute(item, kMDItemWhereFroms));

    NSString *titleContent = @"";
    if (whereFroms) {
        NSString *subtitleLink = [whereFroms lastObject];

        if ([subtitleLink containsString:@"http://www.addic7ed.com/serie/"]) {
            // If downloaded from addic7ed.com and is a serie
            NSArray   *splitedLink = [subtitleLink componentsSeparatedByString:@"/"];

            NSString  *serieTitle = [[splitedLink[4] stringByReplacingOccurrencesOfString:@"_" withString:@" "] stringByRemovingPercentEncoding];
            NSInteger seasonNumber = [splitedLink[5] intValue];
            NSInteger episodeNumber = [splitedLink[6] intValue];
            NSString  *episodeTitle = [[splitedLink[7] stringByReplacingOccurrencesOfString:@"_" withString:@" "] stringByRemovingPercentEncoding];

            titleContent = [NSString stringWithFormat:@"<h1>"
                                                       "<a href=\"%@\">"
                                                       "%@ S%02tdE%02td - %@"
                                                       "</a>"
                                                       "</h1>", subtitleLink, serieTitle, seasonNumber, episodeNumber, episodeTitle];
        }
        else if ([subtitleLink containsString:@"http://www.addic7ed.com/movie/"]) {
            // If downloaded from addic7ed.com and is a movie
            titleContent = [NSString stringWithFormat:@"<h1>"
                                                       "<a href=\"%@\">"
                                                       "Link to movie"
                                                       "</a>"
                                                       "</h1>", subtitleLink];
        }
    }

    // Finding html tags
    NSString *noTagStatus = @"";

    if ([content rangeOfString:@"<[A-Za-z0-9]*\\b[^>]*>"
                       options:NSRegularExpressionSearch].location == NSNotFound)
    {
        noTagStatus = @"<span class=\"green\">YES</span>";
    }
    else {
        noTagStatus = @"<span class=\"red\">NO</span>";
    }

    // Wrap subtitle sequence
    NSString            *sequencePattern = @"(\\d+)\n([\\d:,]+)\\s+-{2}>\\s+([\\d:,]+)\n([\\s\\S]*?(?=(\n){2}|$))";
    NSRegularExpression *sequencesRegex = [NSRegularExpression regularExpressionWithPattern:sequencePattern
                                                                                    options:NSRegularExpressionCaseInsensitive
                                                                                      error:nil];

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

    // Count sequence
    NSRegularExpression *linesRegex = [NSRegularExpression regularExpressionWithPattern:@"<tr>"
                                                                                options:0
                                                                                  error:nil];
    NSUInteger numberOfSequence = [linesRegex numberOfMatchesInString:outputContent
                                                              options:0
                                                                range:NSMakeRange(0, [outputContent length])];

    NSRange searchedRange = NSMakeRange(0, [content length]);
    NSRange lastMatchGroup2 = NSMakeRange(0, 12);

    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\n([\\d:,]+)\\s+-{2}>\\s+([\\d:,]+)\n"
                                                                           options:0
                                                                             error:nil];
    NSTextCheckingResult *match = [regex firstMatchInString:content
                                                    options:0
                                                      range:searchedRange];
    NSString *firstTime = [content substringWithRange:[match rangeAtIndex:1]];

    NSArray *matches = [regex matchesInString:content
                                      options:0
                                        range:searchedRange];
    for (NSTextCheckingResult *match in matches) {
        lastMatchGroup2 = [match rangeAtIndex:2];
    }
    NSString *lastTime = [content substringWithRange:lastMatchGroup2];

    // Preview
    NSString *infoBar = [NSString stringWithFormat:@"%@\n"
                                                    "<ul class=\"infoBar\">\n"
                                                    "<li><b>%tu</b> sequences</li>\n"
                                                    "<li>NoTAG : <b>%@</b></li>"
                                                    "<li><small>%@ | %@</small></li>"
                                                    "</ul>\n", titleContent, numberOfSequence, noTagStatus, firstTime, lastTime];

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
                                                 "</html>", baseStyle, themeStyle, url, infoBar, outputContent];

    QLPreviewRequestSetDataRepresentation(preview,
                                          (__bridge CFDataRef)[html dataUsingEncoding:NSUTF8StringEncoding],
                                          kUTTypeHTML,
                                          NULL);

    return noErr;
}

void CancelPreviewGeneration(void *thisInterface, QLPreviewRequestRef preview)
{
    // Implement only if supported
}
