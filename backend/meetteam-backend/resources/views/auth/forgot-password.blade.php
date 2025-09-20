<!DOCTYPE html>
<html>
<head>
    <title>Mot de passe oublié - Meetteam</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; }
        .container { max-width: 500px; margin: 0 auto; }
        .form-group { margin-bottom: 15px; }
        label { display: block; margin-bottom: 5px; }
        input[type="email"] { width: 100%; padding: 8px; border: 1px solid #ddd; border-radius: 4px; }
        button { background: #4361EE; color: white; padding: 10px 15px; border: none; border-radius: 4px; }
    </style>
</head>
<body>
    <div class="container">
        <h1>Réinitialisation du mot de passe</h1>
        <p>Entrez votre email pour recevoir un lien de réinitialisation.</p>
        
        <form method="POST" action="{{ route('password.email') }}">
            @csrf
            <div class="form-group">
                <label for="email">Email</label>
                <input type="email" id="email" name="email" required>
            </div>
            
            <button type="submit">Envoyer le lien de réinitialisation</button>
        </form>
    </div>
</body>
</html>