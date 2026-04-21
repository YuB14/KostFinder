<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>@yield('title') — KostFinder</title>

    <link rel="stylesheet" href="{{ asset('css/auth.css') }}">

    <link href="https://fonts.googleapis.com/css2?family=Syne:wght@400;600;700;800&family=DM+Sans:ital,wght@0,300;0,400;0,500;1,300&display=swap" rel="stylesheet">
</head>
<body>

    @yield('content')

    @stack('scripts')
</body>
</html>
