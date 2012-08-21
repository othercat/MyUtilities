//
//  utility.m
//
//  Created by Li Richard on 10-8-23.
//  Modified by Li Richard on 12-6-8.
//  Copyright 2010-2012 __Li_Richard__. All rights reserved.
//

char *errorCodeString(OSStatus err, char *string);
int Swap16(void *p);
void SwapASCIIString(UInt16 *buffer, UInt16 length);
BOOL foundObjectInArray(NSMutableArray	*Array,NSObject *anObject);
kern_return_t QueryValueFromGivenDictionary(CFMutableDictionaryRef deviceProperty,const void *key,void *valuePtr);
kern_return_t QueryStringFromGivenDictionary(CFMutableDictionaryRef deviceProperty,const void *key,void *valuePtr);
NSInteger myMessageBox(NSString *title,NSString *msgFormat,NSString *defaultButton,
					   NSString *alternateButton,NSString *otherButton);
kern_return_t IORegistryEntryFindFromChildEntry(io_registry_entry_t		entry,
												const io_name_t			plane,
												io_name_t				matchClassName ,
												io_registry_entry_t		*foundEntry);
kern_return_t IORegistryEntryFindFromParentEntry(io_registry_entry_t		entry,
												 const io_name_t			plane,
												 io_name_t				matchClassName ,
												 io_registry_entry_t		*foundEntry);

char *LogString(char *str);

char *_LogString(char *string,int strlen)
{
	static char     buf[2048];
    //char            *ptr = buf;
    int             i;
	
    //*ptr = '\0';
	
    for(i=0;i<strlen;i++)
	{
		if(isgraph(*(string+i)))	buf[i]=*(string+i);//if it is printable, print it
		else												buf[i]='.';
	}
	buf[i]='\0';
	return buf;
}

// Replace non-printable characters in str with '\'-escaped equivalents.
// This function is used for convenient logging of data traffic.
char *LogString(char *str)
{
    //static char     buf[2048];
	static char  buf [20000*2];
    char            *ptr = buf;
    int             i;
	
    *ptr = '\0';
	
    while (*str)
	{
		if (isprint(*str))
		{
			*ptr++ = *str++;
		}
		else {
			switch(*str)
			{
				case ' ':
					*ptr++ = *str;
					break;
					
				case 27:
					*ptr++ = '\\';
					*ptr++ = 'e';
					break;
					
				case '\t':
					*ptr++ = '\\';
					*ptr++ = 't';
					break;
					
				case '\n':
					*ptr++ = '\\';
					*ptr++ = 'n';
					break;
					
				case '\r':
					*ptr++ = '\\';
					*ptr++ = 'r';
					break;
					
				default:
					i = *str;
					(void)sprintf(ptr, "\\%03o", i);
					ptr += 4;
					break;
			}
			
			str++;
		}
		
		*ptr = '\0';
	}
	
    return buf;
}

char *errorCodeString(OSStatus err, char *string)
{
	if (err == -35)
		strcpy(string,"Volume not found");
	else if (err == -47)
		strcpy(string,"File is busy");
	
	return string;
}

int Swap16(void *p)
{
    * (UInt16 *) p = CFSwapInt16LittleToHost(*(UInt16 *)p);
    return * (UInt16 *) p;
}

void SwapASCIIString(UInt16 *buffer, UInt16 length)
{
	int	index;
	
	for ( index = 0; index < length / 2; index ++ ) {
		buffer[index] = OSSwapInt16 ( buffer[index] );
	}	
}

BOOL foundObjectInArray(NSMutableArray	*Array,NSObject *anObject)
{
	NSEnumerator *enumerator = [Array objectEnumerator];
	id key;
	
	while (key = [enumerator nextObject]) {
		/* code to act on each element as it is returned */
		if ([key isEqual:anObject]  == YES)
			return YES;
	}
	
	return NO;
}

kern_return_t QueryValueFromGivenDictionary(CFMutableDictionaryRef deviceProperty,const void *key,void *valuePtr)
{
	CFTypeRef tmp;
	kern_return_t	kr = kIOReturnSuccess;
	kr = CFDictionaryGetValueIfPresent(deviceProperty, key, &tmp);
	if (!kr) 
		//fprintf(stderr, "Could not get device class property, err = %08x\n",kr);
		fprintf(stderr,"Could not get device class property. (%x)\n", kr);
	else 
		CFNumberGetValue(tmp, kCFNumberIntType, valuePtr);
	
	return kr;
}

kern_return_t QueryStringFromGivenDictionary(CFMutableDictionaryRef deviceProperty,const void *key,void *valuePtr)
{
	CFTypeRef tmp;
	kern_return_t	kr = kIOReturnSuccess;
	kr = CFDictionaryGetValueIfPresent(deviceProperty, key, &tmp);
	if (!kr) 
		//fprintf(stderr, "Could not get device class property, err = %08x\n",kr);
		fprintf(stderr,"Could not get device class property. (%x)\n", kr);
	else 
	{
		//CFShow(tmp);
		//char tmpstr[200];
		CFStringGetCString(tmp,valuePtr,255,kCFStringEncodingUTF8);
		//printf("\nFind String %s \n",(char *)valuePtr);
		//CFNumberGetValue(tmp, kCFNumberIntType, valuePtr);
	}
	
	return kr;
}

NSInteger myMessageBox(NSString *title,NSString *msgFormat,NSString *defaultButton,
					   NSString *alternateButton,NSString *otherButton)
{
	//NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	NSAlert *alert = [[NSAlert alloc] init];
	[alert addButtonWithTitle:defaultButton];
	
	if (alternateButton) {
		[alert addButtonWithTitle:alternateButton];
		if (otherButton) {
			[alert addButtonWithTitle:otherButton];
		}
	}
	
	NSArray *arrBtns = [[NSArray alloc] initWithArray:[alert buttons]];
	
	for (int i = (int)([arrBtns count] - 1),j = 0; i >= 0; --i,++j){
		if (j == 0) {
			[[arrBtns objectAtIndex:j] setKeyEquivalent:@"\r"];
		} else if (j == 1) {
			[[arrBtns objectAtIndex:j] setKeyEquivalent:@"*"];
		} else if (j == 2) {
			[[arrBtns objectAtIndex:j] setKeyEquivalent:@"0"];
		}
	}
	
	
	[alert setMessageText:title];
	[alert setInformativeText:msgFormat];
	[alert setIcon:[NSImage imageNamed:@"iacicon"]];
	[alert setAlertStyle:NSWarningAlertStyle];
	
	NSInteger result = [alert runModal];
	[arrBtns release];
	[alert release];
	//[pool release];
	return NSAlertFirstButtonReturn - result + 1;
	
}

kern_return_t IORegistryEntryFindFromChildEntry(io_registry_entry_t		entry,
												const io_name_t			plane,
												io_name_t				matchClassName ,
												io_registry_entry_t		*foundEntry)
{
	
	io_service_t child  = IO_OBJECT_NULL;
	io_service_t tmpObj = IO_OBJECT_NULL;
	io_name_t	 className;
	kern_return_t			kr							= kIOReturnSuccess;
	
	kr = IOObjectGetClass(entry, className);
	require_string((kr == kIOReturnSuccess), Exit, "IOObjectGetClass failed");
#ifdef DEBUG_OUT
	printf("search class start:\t\"%s\"", className);
#endif
	kr = IORegistryEntryGetChildEntry (entry, kIOServicePlane, &child);
	require_string((kr == kIOReturnSuccess), Exit, "IORegistryEntryGetChildEntry failed");
	
	while (true) {
		
		tmpObj = child;
		/*
		 kr = (NSMutableDictionary *) IORegistryEntryGetNameInPlane (tmpObj,
		 kIOServicePlane,
		 className);
		 
		 require_string((kr == kIOReturnSuccess), Exit, "IORegistryEntryGetNameInPlane failed");
		 */
		
		kr = IOObjectGetClass(tmpObj, className);
		require_string((kr == kIOReturnSuccess), Exit, "IOObjectGetClass failed");
		
		if (strcmp(className,matchClassName) == 0)
		{
#ifdef DEBUG_OUT
			printf("\t-->\t\"%s\"\n", className);
#endif
			*foundEntry = tmpObj;
			return kIOReturnSuccess;
		}
#ifdef DEBUG_OUT		
		printf("\t-->\t\"%s\"", className);
#endif
		
		kr = IORegistryEntryGetChildEntry (tmpObj, kIOServicePlane, &child);
		require_string((kr == kIOReturnSuccess), Exit, "IORegistryEntryGetChildEntry failed");
		
	}
	
Exit:
	printf("\n");
	return kr;
	
}

kern_return_t IORegistryEntryFindFromParentEntry(io_registry_entry_t		entry,
												 const io_name_t			plane,
												 io_name_t				matchClassName ,
												 io_registry_entry_t		*foundEntry)
{
	
	io_service_t parent  = IO_OBJECT_NULL;
	io_service_t tmpObj = IO_OBJECT_NULL;
	io_name_t	 className;
	kern_return_t			kr							= kIOReturnSuccess;
	
	kr = IOObjectGetClass(entry, className);
	require_string((kr == kIOReturnSuccess), Exit, "IOObjectGetClass failed");
#ifdef DEBUG_OUT
	printf("search class start:\t\"%s\"", className);
#endif
	kr = IORegistryEntryGetParentEntry (entry, kIOServicePlane, &parent);
	require_string((kr == kIOReturnSuccess), Exit, "IORegistryEntryGetParentEntry failed");
	
	while (true) {
		
		tmpObj = parent;
		/*
		 kr = (NSMutableDictionary *) IORegistryEntryGetNameInPlane (tmpObj,
		 kIOServicePlane,
		 className);
		 
		 require_string((kr == kIOReturnSuccess), Exit, "IORegistryEntryGetNameInPlane failed");
		 */
		
		kr = IOObjectGetClass(tmpObj, className);
		require_string((kr == kIOReturnSuccess), Exit, "IOObjectGetClass failed");
		
		if (strcmp(className,matchClassName) == 0)
		{
#ifdef DEBUG_OUT
			printf("\t-->\t\"%s\"\n", className);
#endif
			*foundEntry = tmpObj;
			return kIOReturnSuccess;
		}
#ifdef DEBUG_OUT		
		printf("\t-->\t\"%s\"", className);
#endif
		
		kr = IORegistryEntryGetParentEntry (tmpObj, kIOServicePlane, &parent);
		require_string((kr == kIOReturnSuccess), Exit, "IORegistryEntryGetParentEntry failed");
		
	}
	
Exit:
	return kr;
	
}


