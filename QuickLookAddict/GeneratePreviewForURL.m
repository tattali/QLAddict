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
    NSString *styles = [[NSString alloc] initWithContentsOfFile:[[NSBundle bundleWithIdentifier:@"com.sub.QuickLookAddict"]
                                                                                pathForResource:@"styles"
                                                                                         ofType:@"css"]
                                                       encoding:NSUTF8StringEncoding
                                                          error:nil];
    
    NSString *content = [NSString stringWithContentsOfURL:(__bridge NSURL *)url
                                                 encoding:NSUTF8StringEncoding
                                                    error:nil];
    
    NSRegularExpression *regex = [NSRegularExpression
                                  regularExpressionWithPattern:@"(?m)^([0-9]+)$"
                                  options:0 error:nil];
    content = [regex stringByReplacingMatchesInString:content
                                              options:0
                                                range:NSMakeRange(0, [content length])
                                         withTemplate:@"<tr><td class=\"id\">$1</td>"];
    
    regex = [NSRegularExpression regularExpressionWithPattern:@"(?m)^([0-9]{2}:.*-->.*,[0-9]{3})$"
                                                      options:0
                                                        error:nil];
    content = [regex stringByReplacingMatchesInString:content
                                              options:0
                                                range:NSMakeRange(0, [content length])
                                         withTemplate:@"<td class=\"time\">$1</td><td class=\"sub\">"];
    
    content = [[content componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]] componentsJoinedByString:@"<br/>"];
    content = [content stringByReplacingOccurrencesOfString:@"<br/><br/><br/><br/>"
                                                 withString:@"</td></tr>"];
    content = [content stringByReplacingOccurrencesOfString:@"</td><br/><br/>"
                                                 withString:@""];
    content = [content stringByReplacingOccurrencesOfString:@"sub\"><br/><br/>"
                                                 withString:@"sub\">"];
    content = [content stringByReplacingOccurrencesOfString:@"<br/><br/>"
                                                 withString:@"<br/>"];
    
    NSString *html = [NSString stringWithFormat:@"<!DOCTYPE html>\n"
                      "<html>\n"
                      "<head>\n"
                      "<meta charset=\"utf-8\">\n"
                      "<style>\n%@</style>\n"
                      "<base href=\"%@\"/>\n"
                      "</head>\n"
                      "<body>\n"
                      "<table>\n"
                      "%@"
                      "</table>\n"
                      "</body>\n"
                      "</html>", styles, url, content];
    
    QLPreviewRequestSetDataRepresentation(preview, (__bridge CFDataRef)[html dataUsingEncoding:NSUTF8StringEncoding], kUTTypeHTML, NULL);
    
    return noErr;
}

void CancelPreviewGeneration(void *thisInterface, QLPreviewRequestRef preview)
{
    // Implement only if supported
}
