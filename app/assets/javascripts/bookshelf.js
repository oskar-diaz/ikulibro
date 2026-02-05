/*
 * bookshelf.js v1.0.0
 * http://www.codrops.com
 *
 * Licensed under the MIT license.
 * http://www.opensource.org/licenses/mit-license.php
 *
 * Copyright 2014, Codrops
 * http://www.codrops.com
 */

(function () {
  var scrollY = function () {
    return window.pageYOffset || window.document.documentElement.scrollTop;
  };

  var Book = function (el) {
    this.el = el;
    this.book = this.el.querySelector('.book');
    this.ctrls = this.el.querySelector('.buttons');
    this.details = this.el.querySelector('.details');

    this._layout();
    this.bbWrapper = document.getElementById(this.book.getAttribute('data-book'));
    if (this.bbWrapper) {
      this._initBookBlock();
    }
    this._initEvents();
  };

  var supportAnimations =
    'WebkitAnimation' in document.body.style ||
    'MozAnimation' in document.body.style ||
    'msAnimation' in document.body.style ||
    'OAnimation' in document.body.style ||
    'animation' in document.body.style;

  var animEndEventNames = {
    WebkitAnimation: 'webkitAnimationEnd',
    OAnimation: 'oAnimationEnd',
    msAnimation: 'MSAnimationEnd',
    animation: 'animationend'
  };

  var animEndEventName = animEndEventNames[Modernizr.prefixed('animation')];
  var scrollWrap = document.getElementById('scroll-wrap');
  var docscroll = 0;
  var books = document.querySelectorAll('#bookshelf > figure');

  Book.prototype._layout = function () {
    if (Modernizr.csstransforms3d) {
      this.book.innerHTML =
        '<div class="cover"><div class="front"></div><div class="inner inner-left"></div></div>' +
        '<div class="inner inner-right"></div>';
      var perspective = document.createElement('div');
      perspective.className = 'perspective';
      perspective.appendChild(this.book);
      this.el.insertBefore(perspective, this.ctrls);
    }
    this.closeDetailsCtrl = document.createElement('span');
    this.closeDetailsCtrl.className = 'close-details';
    this.details.appendChild(this.closeDetailsCtrl);
  };

  Book.prototype._initBookBlock = function () {
    this._prepareSinglePageForCompact();
    this.bb = new BookBlock(this.bbWrapper.querySelector('.bb-bookblock'), {
      speed: 700,
      shadowSides: 0.8,
      shadowFlip: 0.4
    });
    this.ctrlBBClose = this.bbWrapper.querySelector(' .bb-nav-close');
    this.ctrlBBNext = this.bbWrapper.querySelector(' .bb-nav-next');
    this.ctrlBBPrev = this.bbWrapper.querySelector(' .bb-nav-prev');
  };

  Book.prototype._initEvents = function () {
    var self = this;
    if (!this.ctrls) {
      return;
    }

    if (this.bb) {
      this.ctrls.querySelector('a:nth-child(1)').addEventListener('click', function (ev) {
        ev.preventDefault();
        self._open();
      });

      this.ctrlBBClose.addEventListener('click', function (ev) {
        ev.preventDefault();
        self._close();
      });

      this.ctrlBBNext.addEventListener('click', function (ev) {
        ev.preventDefault();
        self._nextPage();
      });

      this.ctrlBBPrev.addEventListener('click', function (ev) {
        ev.preventDefault();
        self._prevPage();
      });
    }

    this.ctrls.querySelector('a:nth-child(2)').addEventListener('click', function (ev) {
      ev.preventDefault();
      self._showDetails();
    });

    this.closeDetailsCtrl.addEventListener('click', function () {
      self._hideDetails();
    });
  };

  Book.prototype._open = function () {
    if (this._shouldShowMobileHint()) {
      this._showMobileHint();
      return;
    }

    this._ensureScrollableImages();
    this._openNow();
  };

  Book.prototype._openNow = function () {
    docscroll = scrollY();
    classie.add(this.el, 'open');
    classie.remove(this.el, 'close');
    classie.remove(this.bbWrapper, 'hide');
    classie.add(this.bbWrapper, 'show');
    this._applyResponsiveScale();
    this._bindResponsiveResize();

    var onOpenBookEndFn = function (ev) {
      this.removeEventListener(animEndEventName, onOpenBookEndFn);
      document.body.scrollTop = document.documentElement.scrollTop = 0;
      classie.add(scrollWrap, 'hide-overflow');
    };

    if (supportAnimations) {
      this.bbWrapper.addEventListener(animEndEventName, onOpenBookEndFn);
    } else {
      onOpenBookEndFn.call();
    }
  };

  Book.prototype._shouldShowMobileHint = function () {
    if (this._mobileHintShown) {
      return false;
    }

    return (
      window.matchMedia &&
      window.matchMedia('(max-width: 900px) and (orientation: portrait)').matches
    );
  };

  Book.prototype._showMobileHint = function () {
    var self = this;
    this._mobileHintShown = true;
    var message =
      'Pon el móvil en apaisado para poder leer algo porque si no, no vas a ver un pijuelo';

    if (window.alertify && typeof alertify.alert === 'function') {
      alertify.alert(message, function () {
        self._ensureScrollableImages();
        self._openNow();
      });
      return;
    }

    window.alert(message);
    self._ensureScrollableImages();
    self._openNow();
  };

  Book.prototype._applyResponsiveScale = function () {
    if (!this.bbWrapper) {
      return;
    }
    if (window.matchMedia && window.matchMedia('(max-width: 900px)').matches) {
      this._clearResponsiveScale();
      return;
    }

    var width = this.bbWrapper.offsetWidth;
    var height = this.bbWrapper.offsetHeight;
    if (!width || !height) {
      return;
    }

    var scale = Math.min(1, window.innerWidth / width, window.innerHeight / height);
    if (scale >= 0.999) {
      this._clearResponsiveScale();
      return;
    }

    var left = Math.max(0, (window.innerWidth - width * scale) / 2);
    this.bbWrapper.style.transformOrigin = 'top left';
    this.bbWrapper.style.transform = 'scale(' + scale.toFixed(3) + ')';
    this.bbWrapper.style.left = left + 'px';
    this.bbWrapper.style.marginLeft = '0';
  };

  Book.prototype._clearResponsiveScale = function () {
    if (!this.bbWrapper) {
      return;
    }
    this.bbWrapper.style.transform = '';
    this.bbWrapper.style.transformOrigin = '';
    this.bbWrapper.style.left = '';
    this.bbWrapper.style.marginLeft = '';
  };

  Book.prototype._bindResponsiveResize = function () {
    if (this._responsiveResizeBound) {
      return;
    }
    var self = this;
    this._responsiveResizeBound = true;
    this._responsiveResizeHandler = function () {
      self._applyResponsiveScale();
    };
    window.addEventListener('resize', this._responsiveResizeHandler);
  };

  Book.prototype._unbindResponsiveResize = function () {
    if (!this._responsiveResizeBound) {
      return;
    }
    window.removeEventListener('resize', this._responsiveResizeHandler);
    this._responsiveResizeBound = false;
    this._responsiveResizeHandler = null;
  };

  Book.prototype._ensureScrollableImages = function () {
    if (!window.matchMedia || !window.matchMedia('(max-width: 900px) and (orientation: landscape)').matches) {
      return;
    }

    var pages = this.bbWrapper.querySelectorAll('.page-layout-4');
    [].slice.call(pages).forEach(function (page) {
      if (page.querySelector('img.page-image')) {
        return;
      }

      var src = page.getAttribute('data-image');
      if (!src) {
        var bg = window.getComputedStyle(page).backgroundImage;
        if (!bg || bg === 'none') {
          return;
        }
        var match = bg.match(/url\\(["']?(.*?)["']?\\)/);
        if (!match || !match[1]) {
          return;
        }
        src = match[1];
      }

      var img = document.createElement('img');
      img.className = 'page-image';
      img.src = src;
      img.alt = '';
      page.style.backgroundImage = 'none';
      page.appendChild(img);
    });
  };

  Book.prototype._close = function () {
    classie.remove(scrollWrap, 'hide-overflow');
    setTimeout(function () {
      document.body.scrollTop = document.documentElement.scrollTop = docscroll;
    }, 25);
    classie.remove(this.el, 'open');
    classie.add(this.el, 'close');
    classie.remove(this.bbWrapper, 'show');
    classie.add(this.bbWrapper, 'hide');

    var self = this;
    var onCloseBookEndFn = function (ev) {
      this.removeEventListener(animEndEventName, onCloseBookEndFn);
      self.bb.jump(1);
      self._unbindResponsiveResize();
      self._clearResponsiveScale();
      classie.remove(self.el, 'close');
      classie.remove(self.bbWrapper, 'hide');
    };

    if (supportAnimations) {
      this.bbWrapper.addEventListener(animEndEventName, onCloseBookEndFn);
    } else {
      onCloseBookEndFn.call();
    }
  };

  Book.prototype._nextPage = function () {
    this.bb.next();
  };

  Book.prototype._prevPage = function () {
    this.bb.prev();
  };

  Book.prototype._showDetails = function () {
    classie.add(this.el, 'details-open');
  };

  Book.prototype._hideDetails = function () {
    classie.remove(this.el, 'details-open');
  };

  Book.prototype._prepareSinglePageForCompact = function () {
    if (!window.matchMedia) {
      return;
    }

    var isNarrow = window.matchMedia('(max-width: 640px)').matches;
    var isShort = window.matchMedia('(max-height: 700px)').matches;
    if (!isNarrow && !isShort) {
      return;
    }

    var bookblock = this.bbWrapper.querySelector('.bb-bookblock');
    if (!bookblock) {
      return;
    }

    var items = [].slice.call(bookblock.querySelectorAll('.bb-item'));
    if (!items.length) {
      return;
    }

    var fragment = document.createDocumentFragment();

    items.forEach(function (item) {
      var left = item.querySelector('.bb-custom-side.left');
      var right = item.querySelector('.bb-custom-side.right');

      if (left) {
        var leftItem = document.createElement('div');
        leftItem.className = 'bb-item';
        var leftClone = left.cloneNode(true);
        leftClone.classList.remove('right');
        leftClone.classList.add('left');
        leftItem.appendChild(leftClone);
        fragment.appendChild(leftItem);
      }

      if (right) {
        var rightItem = document.createElement('div');
        rightItem.className = 'bb-item';
        var rightClone = right.cloneNode(true);
        rightClone.classList.remove('right');
        rightClone.classList.add('left');
        rightItem.appendChild(rightClone);
        fragment.appendChild(rightItem);
      }
    });

    bookblock.innerHTML = '';
    bookblock.appendChild(fragment);
  };

  var init = function () {
    [].slice.call(books).forEach(function (el) {
      new Book(el);
    });
  };

  init();
})();
