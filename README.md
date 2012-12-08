# Doutzen

The native Mac OS X local symbolicator for QuincyKit.

## Description
Doutzen runs on your Mac OS X computer and periodically connects to your QuinyKit server to check for new crash reports. When it detects a crash report, it tries to symbolicate it using *symbolicatecrash.pl* and uploads the result back to the QuincyKit server. It replaces the local symbolication setup and provides a simple but clear UI and handy notification utilities (such as a menu icon and voice feedback when crashes have been detected).


## Main features
* Easy configuration (host, user/password, check interval);
* Auto start-up, auto symbolicate;
* Icon in menu bar shows progress (symbolication in progress, crashes found, unable to connect);
* Voice-over telling which apps with which versions have been crashed how many times.

## Installation
1. Download source on GitHub and compile using Xcode;
2. Drag the target application (Doutzen.app) to your Application folder;
3. Run the application and configure using the icon in the menu bar.

## Contact
If you have questions or suggestions, visit [www.nielsmouthaan.nl](http://nielsmouthaan.nl/who-am-i/) and use the contact form to contact me.

## Acknowledgements
* Uses *PDKeychainBindingsController* for storing credentials safely in the Mac OS X keychain;
* Uses *StandardPaths* for easily accessing storage paths;
* Uses *symbolicatecrash.pl* to symbolicate crash reports.

## License
Copyright (c) 2012 Niels Mouthaan
All rights reserved.

Permission is hereby granted, free of charge, to any person
obtaining a copy of this software and associated documentation
files (the "Software"), to deal in the Software without
restriction, including without limitation the rights to use,
copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following
conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.