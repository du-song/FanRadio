install:
	rake dmg
	rake feed
	scp -P 50022 appcast/build/* app.tsing.org:/var/vhost/free/app.tsing/app/fanradio/
	cp -L appcast/build/release_notes.html appcast/build/appcast.xml /Users/freewizard/Projects/AppEngine/rollingcode/static/app/fanradio 
