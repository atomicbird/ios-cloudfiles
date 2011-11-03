# The Rackspace Cloud Files SDK for iOS

## Overview

The Rackspace Cloud Files SDK for iOS is a simple library that helps you communicate with the Rackspace Cloud Files API.  You can use this library to upload files, download files, and control metadata and CDN settings in a Rackspace Cloud account.

This library is designed for ARC-enabled projects and uses Foundation classes for HTTP communication and JSON parsing, so no third party dependencies need to be added to your Xcode project.

All API operations have two callback block arguments to allow you to handle success and failure conditions.  If you want to have more control over how you handle HTTP, or if you are using a third party HTTP library such as AFNetworking, you can also access getters for all of the NSURLRequests that the SDK uses.

## Installation

### Installing the Library

There are two ways to install the library:

- Add Source Code to your Xcode Project
- Link to a Static Library

#### Add Source Code to your Xcode Project

Open the Source folder and drag all files into your project.  If you plan on using this library in multiple Xcode projects, you may want to choose not to copy the actual files into your project, and instead refer to them from a single location.

#### Link to a Static Library

To use a static library, open the RackspaceCloudFiles project in Xcode and build the project.  Then, in the Groups and Files pane, expand the Products group and you will see libRackspaceCloudFiles.a.  You can link to this file in the Build Phases tab of your Xcode project settings.

### Installing the Documentation

To install the documentation, go into Xcode Preferences, and choose the Downloads tab.  From there, choose Documentation on the segmented control and press the + button on the bottom left of the window.  For the feed URL, enter the following:

https://github.com/rackspace/ios-cloudfiles/raw/master/RackspaceCloudFiles/appledoc/publish/com.rackspace.Rackspace-Cloud-Files.atom

## Classes

There are four main classes that you can use to communicate with Cloud Files.

#### RSClient

The RSClient class is the root class for this SDK.  You use it to authenticate with your account and work with containers and CDN containers.  You must have a RSClient object available in your code to use the other classes.

You can create a RSClient object with a single line of code:

```Objective-C
RSClient *client = [[RSClient alloc] initWithProvider:RSProviderTypeRackspaceUS username:@"my username" apiKey:@"secret"];
```

Your username is the username you use to login to http://manage.rackspacecloud.com, and your API Key is available in the My Account section of http://manage.rackspacecloud.com.  If you are a UK user, pass RSProviderTypeRackspaceUK to the provider argument in the constructor.  If you are using OpenStack Swift, you can create a RSClient object like this:

```Objective-C
NSURL *url = [NSURL URLWithString:@"https://api.myopenstackdomain.com/"];
RSClient *client = [[RSClient alloc] initWithAuthURL:url username:@"my username" apiKey:@"secret"];
```

Once you have created your object, you can optionally authenticate before performing any operations.  If you do not authenticate, the client will authenticate for you before performing any other API operations.

```Objective-C
[client authenticate:^{

  // authentication was successful

} failure:^(NSHTTPURLResponse *response, NSData *data, NSError *error) {

  // authentication failed.  you can inspect the response, data, and error
  // objects to determine why.

}];
```

#### RSContainer

With RSClient, you can retrieve a NSArray of all of your Cloud Files containers as RSContainer objects.  With a RSContainer object, you can retrieve a list of all files in that container.  You can also upload files and delete files.  Files are referred to as objects.

```Objective-C
[container getObjects:^(NSArray *objects, NSError *jsonError) {
    
    // retrieving objects was successful
    
} failure:^(NSHTTPURLResponse *response, NSData *data, NSError *error) {

    // retrieving objects failed.  you can inspect the response, data,
    // and error objects to determine why.

}];
```

#### RSCDNContainer

RSCDNContainer represents containers that are CDN-enabled and available to the public.  You can use this class to change your CDN settings and purge objects that you no longer want to be available on the CDN.

```Objective-C
[cdnContainer purgeCDNObject:object success:^{
    
    // object purge was successful
    
} failure:^(NSHTTPURLResponse *response, NSData *data, NSError *error) {
    
    NSDictionary *headers = [response allHeaderFields];
    
    // you can only purge once every 3600 seconds, so if you get a
    // X-Purge-Failed-Reason header, that's an acceptable failure
    if (![headers valueForKey:@"X-Purge-Failed-Reason"]) {
        
        // object purge failed for a reason
        
    }
    
}];
```

#### RSStorageObject

RSStorageObject represents an object in the Cloud Files system.  An object is a file and any associated metadata.  With this class, you can upload and download file contents, as well as retrieve and update metadata.

```Objective-C
[object getObjectData:^{
    
    // object.data now contains the file contents
    
} failure:^(NSHTTPURLResponse *response, NSData *data, NSError *error) {
    
    // retrieving object data failed.  you can inspect the response, data,
    // and error objects to determine why.
    
}];
```

## Running the Tests

To run the tests, open the RackspaceCloudFiles project in Xcode, and then open the RackspaceCloudFilesTests.plist file in the RackspaceCloudFilesTests group.  Here you can fill in your username and API key.  If you are a UK user, you will also need to change the auth_url to https://lon.auth.rackspacecloud.com/v1.0

Your API key is available in the My Account section of http://manage.rackspacecloud.com, and http://lon.manage.rackspacecloud.com for UK users.

When you are ready to run the tests, press Command+U, or hold the mouse down over the Run button on the top left corner of the Xcode window and press Test when the popup appears.  Test output will appear in the Xcode console.

## Support and Contribution

The Rackspace Cloud Files SDK is available for free and is open source at http://github.com/rackspace/ios-cloudfiles

The Rackspace Cloud Files SDK is provided under the Apache 2.0 license.  For full text of the license, visit http://www.apache.org/licenses/LICENSE-2.0

Contribution is welcome and encouraged!  We welcome both code contributions and bug reports in Github Issues.  If you contribute code, be sure that your code is tested and that all tests pass.

Feel free to contact Mike Mayo at mike.mayo@rackspace.com if you have any trouble using the library.


