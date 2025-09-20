<?php

namespace App\Notifications;

use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Notifications\Messages\MailMessage;
use Illuminate\Notifications\Notification;
use Illuminate\Support\Facades\Lang;

class CustomResetPassword extends Notification
{
    use Queueable;

    public $token;

    public function __construct($token)
    {
        $this->token = $token;
    }

    public function via($notifiable)
    {
        return ['mail'];
    }

    public function toMail($notifiable)
{
    // URL pour le frontend web (temporaire)
    $url = url(route('password.reset', [
        'token' => $this->token,
        'email' => $notifiable->email
    ], false));

    return (new MailMessage)
        ->subject('Réinitialisation de votre mot de passe Meetteam')
        ->line('Vous recevez cet email parce que nous avons reçu une demande de réinitialisation de mot de passe pour votre compte.')
        ->action('Réinitialiser le mot de passe', $url)
        ->line('Ce lien expirera dans 60 minutes.')
        ->line('Si vous n\'avez pas demandé de réinitialisation, ignorez simplement cet email.');
}
}