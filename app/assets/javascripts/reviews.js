$(function () {
  var $tabs = $('.reviews-tabs .tab-link');
  if ($tabs.length === 0) {
    return;
  }

  var $panels = $('.reviews-panel');

  var showTab = function (name, pushState) {
    $panels.hide();
    $panels.filter('[data-tab="' + name + '"]').show();
    $tabs.removeClass('active');
    $tabs.filter('[data-tab="' + name + '"]').addClass('active');
    if (pushState && window.history && window.history.replaceState) {
      var url = new URL(window.location.href);
      url.searchParams.set('tab', name);
      window.history.replaceState({}, '', url.toString());
    }
  };

  $tabs.on('click', function (ev) {
    ev.preventDefault();
    showTab($(this).data('tab'), true);
  });

  var initialTab = (new URL(window.location.href)).searchParams.get('tab');
  if (initialTab && $tabs.filter('[data-tab="' + initialTab + '"]').length) {
    showTab(initialTab, false);
  } else {
    showTab($tabs.first().data('tab'), false);
  }

  var $copyToast = $('.reviews-copy-toast');
  var copyToastTimer = null;
  var copyButtonTimer = null;

  if ($copyToast.length === 0) {
    $copyToast = $('<div class="reviews-copy-toast" role="status" aria-live="polite"></div>');
    $('body').append($copyToast);
  }

  var showCopyToast = function (message) {
    if ($copyToast.length === 0) {
      return;
    }

    $copyToast.text(message);
    $copyToast.addClass('is-visible');

    if (copyToastTimer) {
      window.clearTimeout(copyToastTimer);
    }

    copyToastTimer = window.setTimeout(function () {
      $copyToast.removeClass('is-visible');
    }, 1800);
  };

  var showCopiedState = function ($button, copiedLabel, defaultLabel) {
    if ($button.length === 0) {
      return;
    }

    $button.text(copiedLabel);

    if (copyButtonTimer) {
      window.clearTimeout(copyButtonTimer);
    }

    copyButtonTimer = window.setTimeout(function () {
      $button.text(defaultLabel);
    }, 1800);
  };

  var copyText = function (text) {
    if (navigator.clipboard && typeof navigator.clipboard.writeText === 'function') {
      return navigator.clipboard.writeText(text);
    }

    return new Promise(function (resolve, reject) {
      var $temp = $('<input type="text" class="review-share-temp" readonly>');
      $('body').append($temp);
      $temp.val(text);
      $temp[0].focus();
      $temp[0].select();

      try {
        var copied = document.execCommand('copy');
        $temp.remove();
        if (copied) {
          resolve();
        } else {
          reject(new Error('copy failed'));
        }
      } catch (error) {
        $temp.remove();
        reject(error);
      }
    });
  };

  $(document).on('click', '.review-share', function () {
    var $button = $(this);
    var shareUrl = $button.data('share-url');
    var copiedLabel = $button.data('copied-label') || 'Enlace copiado';
    var defaultLabel = $button.data('default-label') || 'Compartir';

    if (!shareUrl) {
      return;
    }

    copyText(shareUrl)
      .then(function () {
        showCopiedState($button, copiedLabel, defaultLabel);
        showCopyToast(copiedLabel);
      })
      .catch(function () {
        if (window.alertify && typeof alertify.error === 'function') {
          alertify.error('No se ha podido copiar el enlace', 3);
        }
      });
  });
});
