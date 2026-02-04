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
});
