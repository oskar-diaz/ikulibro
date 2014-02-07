$ ->
  $('#send').click ->
    $.ajax
      type: 'POST'
      url: '/contacto'
      data:
        _method: "put"
        name: $('#name').val()
        email: $('#email').val()
        address: $('#email').val()
        comments: $('#email').val()
      complete: (data) ->
        $('#pedirLibro').foundation('reveal', 'close')
        alertify.alert(data.responseText)
