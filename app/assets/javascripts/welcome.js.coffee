$ ->
  $('#send').click ->
    $.ajax
      type: 'POST'
      url: '/contacto'
      data:
        _method: "put"
        name: $('#nombre').val()
        email: $('#email').val()
        address: $('#address').val()
        comments: $('#comments').val()
      complete: (data) ->
        $('#pedirLibro').foundation('reveal', 'close')
        alertify.alert(data.responseText)
