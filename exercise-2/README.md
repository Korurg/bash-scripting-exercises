необходимо будет связать работу трёх контейнеров:
1) nginx как реверс-прокси для wordpress;
   * как источник для **/** должен использоваться каталог **/opt/html/root/**
     * в нём должен быть сгенерирован **static.html** в которого должны быть записаны данные в виде валидного HTML в BODY:
        * самое популярное слово и его частота использования (из задания про скачиваение «Война и Мир»)
        * ниже вывод **/etc/os-release** (может быть другой файл, в зависимости от выбранного родительского образа)
     * в нём должен быть сгенерирован **index.html** в котором должны быть выведены все переменные окружения контейнера (в том числе и те, что мы укажем при запуске контейнера)
   * по пути **/wp/** должен быть реверс-прокси к wordpress, данный путь должно быть настраиваемым через переменную окружения
     * доступ к **/wp/** должен быть через **web basic auth**, пользователь указывается при сборке в качестве аргумента, пароль в виде переменной окружения.
   * путь **/upload/** это **/opt/html/upload/** который должен монтироваться из хост системы для постоянного хранения
2) wordpress, просто wordpress;
3) mariadb/mysql, в качестве базы данных для wordpress;