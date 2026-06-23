
try {
	a = new Array(1);
	a.at(0)
}
catch(e) {
	ele = document.createElement('p')
	ele.innerText = 'Your browser/JS engine doesn\'t support Array.at(). Therefore Mastodon cannot be loaded'
	document.body.prepend(ele)
}




