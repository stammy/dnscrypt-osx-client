<!DOCTYPE html>
<html lang='en'>
  <head>
    <meta charset='utf-8' />
    <title>DNSCrypt feedback form</title>
    <style type='text/css'>
      body {
        font-family: arial, helvetica, sans-serif;
        margin: 0; }

      h1 {
        margin: 0; }

      form {
        margin: 0 auto;
        width: 500px; }
        form p {
          margin: 0.25em 0; }
        form .error {
          background: #ffbbbb;
          color: black; }

      fieldset {
        border: none;
        padding: 0; }

      label {
        float: left;
        width: 100px;
        text-align: right;
        padding-right: 1em; }

      input {
        width: 200px; }

      input[type=submit] {
        width: auto; }

      textarea {
        width: 300px;
        height: 170px; }

      #submit {
        text-align: center; }
    </style>
  </head>
  <body>
    <form action='{{form_url}}' method='post'>
      <h1>Feedback</h1>
      <fieldset>
        <p>
          <label for='name'>Name:</label>
          <input autofocus='autofocus' class='{{class_name}}' name='name' required='required' type='text' value='{{name}}' />
        </p>
        <p>
          <label for='email'>Email:</label>
          <input class='{{class_email}}' name='email' placeholder='email@example.com' required='required' type='email' value='{{email}}' />
        </p>
        <p>
          <label for='feedback'>Feedback:</label>
          <textarea class='{{class_feedback}}' name='feedback'>{{feedback}}</textarea>
        </p>
      </fieldset>
      <fieldset id='submit'>
        <input type='submit' />
      </fieldset>
    </form>
  </body>
</html>
