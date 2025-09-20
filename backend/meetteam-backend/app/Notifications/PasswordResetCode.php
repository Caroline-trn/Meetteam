<?php

namespace App\Notifications;

use Illuminate\Bus\Queueable;
use Illuminate\Notifications\Notification;
use Illuminate\Notifications\Messages\MailMessage;

class PasswordResetCode extends Notification
{
    use Queueable;

    public $code;

    public function __construct($code)
    {
        $this->code = $code;
    }

    public function via($notifiable)
    {
        return ['mail'];
    }

    public function toMail($notifiable)
    {
        return (new MailMessage)
            ->subject('🔐 Code de réinitialisation Meetteam')
            ->greeting('Bonjour !')
            ->line('Vous avez demandé la réinitialisation de votre mot de passe.')
            ->line('**Votre code de réinitialisation est :**')
            ->line('## ' . $this->code)
            ->line('Ce code est valide pendant 15 minutes.')
            ->line('Si vous n\'avez pas fait cette demande, ignorez simplement cet email.')
            ->salutation('Cordialement,<br>L\'équipe Meetteam');
    }
}