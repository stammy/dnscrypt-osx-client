<?php

error_reporting(E_ALL);

function strip_slashes_from_user_data(&$array) {
    foreach($array as $k => $v) {
        if (is_array($v)) {
            strip_slashes_from_user_data($array[$k]);
            continue;
        }
        $array[$k] = stripslashes($v);
    }
}

if (get_magic_quotes_gpc()) {
    strip_slashes_from_user_data($_GET);
    strip_slashes_from_user_data($_POST);
    strip_slashes_from_user_data($_COOKIE);
}

function render_headers() {
    header('X-Frame-Options: sameorigin');
    header('X-XSS-Protection: 1; mode=block');
    header('X-Content-Security-Policy: allow \'self\'');
}

function render_tpl($template, $vars) {
    $tpl = @file_get_contents($template);
    if (empty($tpl)) {
        throw new Exception("template");
    }
    foreach ($vars as $key => $value) {
        foreach (array_keys($vars) as $key_) {
            if (strstr($value, '{{' . $key . '}}') !== FALSE) {
                $value = '';
            }
        }
        $tpl = str_replace('{{' . $key . '}}',
                           htmlspecialchars($value),
                           $tpl);
    }
    echo $tpl;
}

$authenticity_token = isset($_GET['authenticity_token']) ?
  (string) $_GET['authenticity_token'] : '';
$name = trim(isset($_POST['name']) ? (string) $_POST['name'] : '');
$email = trim(isset($_POST['email']) ? (string) $_POST['email'] : '');
$feedback = trim(isset($_POST['feedback']) ? (string) $_POST['feedback'] : '');

$form_url = $_SERVER['REQUEST_URI'] . '?' .
  http_build_query(array('authenticity_token' => $authenticity_token));

render_headers();

render_tpl('feedback.tpl', array('authenticity_token' => $authenticity_token,
                                 'name' => $name, 'email' => $email,
                                 'feedback' => $feedback,
                                 'form_url' => $form_url));
