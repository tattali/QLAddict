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
    NSString *domainName = @"com.sub.QuickLookAddict";
    
    // Use NSUserDefaults for theme switch
    NSDictionary *defaults = [[NSUserDefaults standardUserDefaults] persistentDomainForName:domainName];
    NSString *styleName = [defaults valueForKey:@"style"];
    
    if (styleName == nil || [styleName.lowercaseString isEqual:@"default"]) {
        styleName = @"addic7ed";
    }
    
    // Stylesheets
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
    
    // Finding html tags
    NSString *tagStatus = @"";
    
    if ([content rangeOfString:@"<[A-Za-z0-9]*\\b[\\^>]*>"
                       options:NSRegularExpressionSearch].location == NSNotFound)
    {
        tagStatus = @"<span class=\"green\">YES</span>";
    }
    else {
        tagStatus = @"<span class=\"red\">NO</span>";
    }
    
    // Wrap subtitle sequence
    NSString *pattern = @"(\\d+)\r\n([\\d:,]+)\\s+-{2}>\\s+([\\d:,]+)\r\n([\\s\\S]*?(?=(\r\n){2}|$))";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:nil];
    content = [regex stringByReplacingMatchesInString:content
                                              options:0
                                                range:NSMakeRange(0, [content length])
                                         withTemplate:@"<tr>"
                                                    "<td class='id'>"
                                                    "$1"
                                                    "</td>"
                                                    "<td class='time'>"
                                                    "$2 --> $3"
                                                    "</td>"
                                                    "<td class='sub'>"
                                                    "$4"
                                                    "</td>"
                                                    "</tr>"];
    
    // Count sequence
    regex = [NSRegularExpression regularExpressionWithPattern:@"<tr>"
                                                      options:0
                                                        error:nil];
    NSUInteger countSequence = [regex numberOfMatchesInString:content
                                                 options:0
                                                   range:NSMakeRange(0, [content length])];
    
    // Preview
    NSString *infoBar = [NSString stringWithFormat:@"<li><b>%lu</b> sequences</li>\n"
                         "<li>NoTAG : <b>%@</b></li>",
                         (unsigned long)countSequence, tagStatus];
    
    NSString *html = [NSString stringWithFormat:@"<!DOCTYPE html>\n"
                      "<html>\n"
                      "<head>\n"
                      "<meta charset=\"utf-8\">\n"
                      "<style>\n%@</style>\n"
                      "<base href=\"%@\"/>\n"
                      "</head>\n"
                      "<body>\n"
                      "<ul class=\"infoBar\">\n%@</ul>\n"
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
