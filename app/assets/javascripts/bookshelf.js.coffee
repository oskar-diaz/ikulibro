###
bookshelf.js v1.0.0
http://www.codrops.com

Licensed under the MIT license.
http://www.opensource.org/licenses/mit-license.php

Copyright 2014, Codrops
http://www.codrops.com
###
(->

  # animation end event name
  scrollY = ->
    window.pageYOffset or window.document.documentElement.scrollTop
  Book = (el) ->
    @el = el
    @book = @el.querySelector(".book")
    @ctrls = @el.querySelector(".buttons")
    @details = @el.querySelector(".details")

    # create the necessary structure for the books to rotate in 3d
    @_layout()
    @bbWrapper = document.getElementById(@book.getAttribute("data-book"))
    @_initBookBlock()  if @bbWrapper
    @_initEvents()

  # initialize bookblock instance

  # boobkblock controls

  # reset bookblock starting page
  init = ->
    [].slice.call(books).forEach (el) ->
      new Book(el)

  supportAnimations = "WebkitAnimation" of document.body.style or "MozAnimation" of document.body.style or "msAnimation" of document.body.style or "OAnimation" of document.body.style or "animation" of document.body.style
  animEndEventNames =
    WebkitAnimation: "webkitAnimationEnd"
    OAnimation: "oAnimationEnd"
    msAnimation: "MSAnimationEnd"
    animation: "animationend"

  animEndEventName = animEndEventNames[Modernizr.prefixed("animation")]
  scrollWrap = document.getElementById("scroll-wrap")
  docscroll = 0
  books = document.querySelectorAll("#bookshelf > figure")
  Book::_layout = ->
    if Modernizr.csstransforms3d
      @book.innerHTML = "<div class=\"cover\"><div class=\"front\"></div><div class=\"inner inner-left\"></div></div><div class=\"inner inner-right\"></div>"
      perspective = document.createElement("div")
      perspective.className = "perspective"
      perspective.appendChild @book
      @el.insertBefore perspective, @ctrls
    @closeDetailsCtrl = document.createElement("span")
    @closeDetailsCtrl.className = "close-details"
    @details.appendChild @closeDetailsCtrl

  Book::_initBookBlock = ->
    @bb = new BookBlock(@bbWrapper.querySelector(".bb-bookblock"),
      speed: 700
      shadowSides: 0.8
      shadowFlip: 0.4
    )
    @ctrlBBClose = @bbWrapper.querySelector(" .bb-nav-close")
    @ctrlBBNext = @bbWrapper.querySelector(" .bb-nav-next")
    @ctrlBBPrev = @bbWrapper.querySelector(" .bb-nav-prev")

  Book::_initEvents = ->
    self = this
    return  unless @ctrls
    if @bb
      @ctrls.querySelector("a:nth-child(1)").addEventListener "click", (ev) ->
        ev.preventDefault()
        self._open()

      @ctrlBBClose.addEventListener "click", (ev) ->
        ev.preventDefault()
        self._close()

      @ctrlBBNext.addEventListener "click", (ev) ->
        ev.preventDefault()
        self._nextPage()

      @ctrlBBPrev.addEventListener "click", (ev) ->
        ev.preventDefault()
        self._prevPage()

    @ctrls.querySelector("a:nth-child(2)").addEventListener "click", (ev) ->
      ev.preventDefault()
      self._showDetails()

    @closeDetailsCtrl.addEventListener "click", ->
      self._hideDetails()


  Book::_open = ->
    docscroll = scrollY()
    classie.add @el, "open"
    classie.add @bbWrapper, "show"
    self = this
    onOpenBookEndFn = (ev) ->
      @removeEventListener animEndEventName, onOpenBookEndFn
      document.body.scrollTop = document.documentElement.scrollTop = 0
      classie.add scrollWrap, "hide-overflow"

    if supportAnimations
      @bbWrapper.addEventListener animEndEventName, onOpenBookEndFn
    else
      onOpenBookEndFn.call()

  Book::_close = ->
    classie.remove scrollWrap, "hide-overflow"
    setTimeout (->
      document.body.scrollTop = document.documentElement.scrollTop = docscroll
    ), 25
    classie.remove @el, "open"
    classie.add @el, "close"
    classie.remove @bbWrapper, "show"
    classie.add @bbWrapper, "hide"
    self = this
    onCloseBookEndFn = (ev) ->
      @removeEventListener animEndEventName, onCloseBookEndFn
      self.bb.jump 1
      classie.remove self.el, "close"
      classie.remove self.bbWrapper, "hide"

    if supportAnimations
      @bbWrapper.addEventListener animEndEventName, onCloseBookEndFn
    else
      onCloseBookEndFn.call()

  Book::_nextPage = ->
    @bb.next()

  Book::_prevPage = ->
    @bb.prev()

  Book::_showDetails = ->
    classie.add @el, "details-open"

  Book::_hideDetails = ->
    classie.remove @el, "details-open"

  init()
)()