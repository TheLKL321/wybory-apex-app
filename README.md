# wybory-apex-app
Przykładowa aplikacja Oracle Apex, pozwalająca na przeprowadzanie wyborów wśród studentów

Aby zainstalować, należy w serwisie apex.oracle, App Builder zaimportować plik f82458.sql, oraz w SQL Scripts uruchomić skrypt wybory.sql </br>
APLIKACJA NIE NADAJE SIĘ DO UŻYTKU W PRAWDZIWYCH WYBORACH Z WRAŻLIWYMI DANYMI

* Zademonstrowana jest przykładowa aplikacja korzystająca z prostej bazy danych
* Zakłada się stosunkowo dużą liczbę studentów
* HASŁA NIE SĄ SZYFROWANE, ponieważ Oracle nie pozwala na korzystanie z pakietu DBMS_CRYPTO w apex.oracle (pomimo używania go w dokumentacji) a pisanie własnej funkcji hashującej w PL/SQL zdecydowanie przerasta ambicje tego projektu
* Jeżeli jakaś biedna dusza musi stworzyć jakąś aplikację na tej platformie i jest wystarczająco zdesperowana żeby szukać przykładów po polsku, można do mnie pisać