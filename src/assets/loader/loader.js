var webComponentsSupported = ('registerElement' in document
    && 'import' in document.createElement('link')
    && 'content' in document.createElement('template'));

if (!webComponentsSupported) {
  var script = document.createElement('script');
  script.async = true;
  script.src = '/bower_components/webcomponentsjs/webcomponents-lite.min.js';
  script.onload = finishLazyLoading;
  document.head.appendChild(script);
} else {
  finishLazyLoading();
}

function finishLazyLoading() {
  window.Polymer = window.Polymer || {dom: 'shadow'};

  var onImportLoaded = function() {
    var loadEl = document.getElementById('splash-screen');
    loadEl.addEventListener('transitionend', loadEl.remove);

    document.body.classList.remove('loading');

  };

  var link = document.querySelector('#filesToLoad');

  if (link.import && link.import.readyState === 'complete') {
    onImportLoaded();
  } else {
    link.addEventListener('load', onImportLoaded);
  }
}
