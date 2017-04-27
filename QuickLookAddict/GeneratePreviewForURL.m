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
    NSString *styleName = [defaults valueForKey:@"theme"];

    if (styleName == nil || [styleName.lowercaseString isEqual:@"default"]) {
        styleName = @"addic7ed";
    }

    // Import stylesheets
    NSString *styles = [[NSString alloc]
                        initWithContentsOfFile:[[NSBundle bundleWithIdentifier:domainName]
                                                               pathForResource:styleName
                                                                        ofType:@"css"]
                                      encoding:NSUTF8StringEncoding
                                         error:nil];

    // Get content from giving url
    NSString *content = [NSString stringWithContentsOfURL:(__bridge NSURL *)url
                                                 encoding:NSUTF8StringEncoding
                                                    error:nil];

    // Get title and link
    MDItemRef item = MDItemCreateWithURL(kCFAllocatorDefault, url);
    NSArray *whereFroms = CFBridgingRelease(MDItemCopyAttribute(item, kMDItemWhereFroms));

    NSString *titleContent = @"";
    if (whereFroms) {
        NSString *subtitleLink = [whereFroms lastObject];

        if ([subtitleLink containsString:@"http://www.addic7ed.com/serie/"]) {
            NSArray *splitedLink = [subtitleLink componentsSeparatedByString:@"/"];

            NSString *serieTitle = splitedLink[4];
            NSInteger seasonNumber = [splitedLink[5] intValue];
            NSInteger episodeNumber = [splitedLink[6] intValue];
            NSString *episodeTitle = [splitedLink[7] stringByReplacingOccurrencesOfString:@"_" withString:@" "];

            titleContent = [NSString stringWithFormat:@"<h1>"
                            "<a href=\"%@\">"
                            "%@ S%02ldE%02ld - %@"
                            "</a>"
                            "</h1>", subtitleLink, serieTitle, (long)seasonNumber, (long)episodeNumber, episodeTitle];
        }
    }

    // Finding html tags
    NSString *tagStatus = @"";

    if ([content rangeOfString:@"<[A-Za-z0-9]*\\b[^>]*>"
                       options:NSRegularExpressionSearch].location == NSNotFound)
    {
        tagStatus = @"<span class=\"green\">YES</span>";
    }
    else {
        tagStatus = @"<span class=\"red\">NO</span>";
    }

    // Wrap subtitle sequence
    NSString *sequencePattern = @"(\\d+)\r\n([\\d:,]+)\\s+-{2}>\\s+([\\d:,]+)\r\n([\\s\\S]*?(?=(\r\n){2}|$))";
    NSRegularExpression *sequencesSelector = [NSRegularExpression regularExpressionWithPattern:sequencePattern
                                                                                       options:NSRegularExpressionCaseInsensitive
                                                                                         error:nil];
    content = [sequencesSelector stringByReplacingMatchesInString:content
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
    NSRegularExpression *linesSelector = [NSRegularExpression regularExpressionWithPattern:@"<tr>"
                                                                                   options:0
                                                                                     error:nil];
    NSUInteger countSequence = [linesSelector numberOfMatchesInString:content
                                                              options:0
                                                                range:NSMakeRange(0, [content length])];

    // Preview
    NSString *infoBar = [NSString stringWithFormat:@"%@\n"
                         "<ul class=\"infoBar\">\n"
                         "<li><b>%lu</b> sequences</li>\n"
                         "<li>NoTAG : <b>%@</b></li>"
                         "</ul>\n", titleContent, (unsigned long)countSequence, tagStatus];

    NSString *html = [NSString stringWithFormat:@"<!DOCTYPE html>\n"
                      "<html>\n"
                      "<head>\n"
                      "<meta charset=\"utf-8\">\n"
                      "<style>\n%@</style>\n"
                      "<base href=\"%@\"/>\n"
                      "</head>\n"
                      "<body>\n"
                      "%@"
                      "<table>\n"
                      "%@"
                      "</table>\n"
                      "</body>\n"
                      "</html>", styles, url, infoBar, content];

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
