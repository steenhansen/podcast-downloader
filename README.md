
## Podcast-Downloader for Windows 7+
Download only raw EXEs [https://github.com/steenhansen/podcast-downloader/raw/master/podcast-downloader-exes.zip](https://github.com/steenhansen/podcast-downloader/raw/master/podcast-downloader-exes.zip) from GitHub to run as Windows desktop programs. You will get a red colored 'Windows protected your PC' warning.

#### Joe Rogan's podcasts are only on Spotify, except for #1109 in the RSS feed https://joeroganexp.libsyn.com/rss.

### RSS feeds that don't work anymore that are in the menu.

#### Video
 - Microsoft Channel 9
 - Aljezeera Documentaries

#### Images
 - Smithsonian Photos

[Download the console and GUI EXEs without source code](https://github.com/steenhansen/podcast-downloader/raw/master/podcast-downloader-exes.zip), no installation is needed. Copy files from ZIP to a new folder to avoid the Microsoft Defender SmartScreen pop-up when running gui\_podcast\_downloader.exe.  

This desktop program downloads podcast episodes onto your computer be they MP3s, PDFs, MP4s, or images. The rationale for this program is that some podcasts disappear when hosting is cancelled. And some podcast feeds, such as [The Joe Rogan Experience - libsynpro.com](http://joeroganexp.joerogan.libsynpro.com/rss) with 1,400+ episodes, only have the last 248 episodes listed on iTunes. For example the episodes listed on [The Joe Rogan Experience - iTunes](https://podcasts.apple.com/us/podcast/the-joe-rogan-experience/id360084272)  currently spans only from #1,212 to #1,460.

Moreover, the program also tests that an RSS feed points to the correct files. This can be tried by downloading [The SFFaudio Public Domain PDF](https://sffaudio.herokuapp.com/pdf/rss) RSS feed which contains 6,000+ files.

The program was developed with the open source [Lazarus-IDE](https://www.lazarus-ide.org/). There is both a normal Windows program and a console version. 

<a name="screen-shot"></a>
The project contains [tests](https://github.com/steenhansen/podcast-downloader/tree/master/the_tests), [dependency instructions](https://github.com/steenhansen/podcast-downloader/blob/master/compile-info/gui-podcast-downloader-dependencies.png), [compile options](https://github.com/steenhansen/podcast-downloader/blob/master/compile-info/compile-options.png), [class information](https://github.com/steenhansen/podcast-downloader/blob/master/compile-info/var-types.txt), and [debugging information](https://github.com/steenhansen/podcast-downloader/blob/master/compile-info/debug-server.png).


![GUI version](https://raw.githubusercontent.com/steenhansen/podcast-downloader/master/lib/gui-downloader.png)

![Console version](https://raw.githubusercontent.com/steenhansen/podcast-downloader/master/lib/console-downloader.png)

The console version has no search capabilities, every podcast episode will be downloaded to a folder on the desktop.

Downloading of files is always via accretion so the given default directories can be safely and continuously used to backup podcasts. Files are only copied once, never over-written. Episodes are downloaded newest first, in the order they appear in the RSS feed.

#### System Setup for Lazarus 2.0.10

[Download Windows 32bit Lazarus 2.0.10](https://sourceforge.net/projects/lazarus/files/Lazarus%20Windows%2032%20bits/Lazarus%202.0.10/lazarus-2.0.10-fpc-3.2.0-win32.exe/download) from [SourceForge](https://sourceforge.net/projects/lazarus/files/Lazarus%20Windows%2032%20bits/Lazarus%202.0.10/)

Before loading the Podcast-Downloader source code into Lazarus IDE, install the BGRAControls package into the environment.

	- In the Lazarus menu choose Package | Online Package Manager
	
	- Check BGRAControls checkbox
	
	- Install from repository
	
	- Package "bgracontrols.lpk" depends on package "bgrabitmappack.lpk".
	  Resolve Dependency? "Yes to All"
	
	- "Yes" to rebuild Lazarus with a profile: Normal IDG?

Now source code can be loaded, compiled and run without issue.

#### Created by
[Steen Hansen](https://github.com/steenhansen) using the open source cross-platform [Lazarus](https://www.lazarus-ide.org/) ide on Windows 10.










































