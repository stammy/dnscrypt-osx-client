<?php

error_reporting(E_ALL);

define('FEEDBACK_RECIPIENT', 'DNSCrypt Feedback <dnscrypt@example.com>');
define('FEEDBACK_SUBJECT', 'DNSCrypt Feedback');

function strip_slashes_from_user_data(&$array) {
    foreach($array as $k => $v) {
        if (is_array($v)) {
            strip_slashes_from_user_data($array[$k]);
            continue;
        }
        $array[$k] = stripslashes($v);
    }
}

function disable_magic_quotes() {
    if (get_magic_quotes_gpc()) {
        strip_slashes_from_user_data($_GET);
        strip_slashes_from_user_data($_POST);
        strip_slashes_from_user_data($_COOKIE);
    }
}

function render_headers() {
    header('X-Frame-Options: sameorigin');
    header('X-XSS-Protection: 1; mode=block');
    header('X-Content-Security-Policy: allow \'self\'');
    header('Cache-Control: private, max-age=3600');
    header('Expires: ' . date('r', time() + 3600));
}

function render_tpl($template, $vars) {
    $tpl = @file_get_contents($template);
    if (empty($tpl)) {
        throw new Exception('template');
    }
    foreach ($vars as $key => $value) {
        foreach (array_keys($vars) as $key_) {
            if (strstr($value, '{{' . $key . '}}') !== FALSE) {
                $value = '';
            }
        }
        $tpl = str_replace('{{' . $key . '}}', htmlspecialchars($value), $tpl);
    }
    echo $tpl;
}

function redirect_to_sent_page($uri) {
    header('HTTP/1.1 303 See other');
    header('Location: ' . $uri);
    exit;
}

function _send_email($name, $email, $feedback) {
    $from = mb_encode_mimeheader($name, 'UTF-8') . '<' . $email . '>';
    $to = FEEDBACK_RECIPIENT;
    $subject = mb_encode_mimeheader(FEEDBACK_SUBJECT, 'UTF-8');
    $body = addslashes($feedback);

    return send_email($from, $to, $subject, $body);
}

function send_form($name, $email, $feedback) {
    if (_send_email($name, $email, $feedback) !== TRUE) {
        redirect_to_sent_page($_SERVER['SCRIPT_NAME']);
    }
    redirect_to_sent_page('sent.html');
}

function process_feedback(&$errors, &$name, &$email, &$feedback) {
    $name = trim(isset($_POST['name']) ? (string) $_POST['name'] : '');
    $email = trim(isset($_POST['email']) ? (string) $_POST['email'] : '');
    $feedback = trim(isset($_POST['feedback']) ?
                     (string) $_POST['feedback'] : '');
    if (empty($name)) {
        array_push($errors, 'name');
    }
    if (! filter_var($email, FILTER_VALIDATE_EMAIL)) {
        array_push($errors, 'email');
    }
    if (empty($feedback)) {
        array_push($errors, 'feedback');
    }
    if (! empty($errors)) {
        return;
    }
    session_start();
    if (empty($_SESSION['authenticity_token']) ||
        $_GET['authenticity_token'] !== $_SESSION['authenticity_token']) {
        return;
    }
    send_form($name, $email, $feedback);
    unset($_SESSION['authenticity_token']);
}

disable_magic_quotes();

render_headers();

$errors = array();
$name = $email = $feedback = '';

if ($_SERVER['REQUEST_METHOD'] === 'POST' &&
    !empty($_GET['authenticity_token'])) {
    process_feedback($errors, $name, $email, $feedback);
}

if (session_id() === '') {
    session_start();
}
$authenticity_token = md5(uniqid(__FILE__, TRUE));
$_SESSION['authenticity_token'] = $authenticity_token;

$form_url = $_SERVER['SCRIPT_NAME'] . '?' .
  http_build_query(array('authenticity_token' => $authenticity_token));

$vars = array('name' => $name,
              'email' => $email,
              'feedback' => $feedback,
              'form_url' => $form_url);

foreach ($errors as $error) {
    $vars['class_' . $error] = 'error';
}

render_tpl('feedback.tpl', $vars + $errors);
