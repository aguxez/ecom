// Simple client-side form validation
if (window.location.href.match(/\/register\/new/)) {
  $('#submit').prop('disabled', true);
  $('#submit').text('Las contraseñas no coinciden');

  let password_field = document.getElementById('user_password');
  let password_confirm_field = document.getElementById('user_password_confirmation');

  let password, password_confirm;


  password_field.addEventListener('change', event => {
    password = event.target.value;
  });

  password_confirm_field.addEventListener('change', event => {
    password_confirm = event.target.value;

    if (password === password_confirm) {
      $('#submit').prop('disabled', false);
      $('#submit').text('Enviar');
    }
  });
};
