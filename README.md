## Bulls and Cows project for the Functional programming with Elixir course at FMI

При стартиране на приложението с `iex -S mix`, то започва да "слуша" на порт 4040 за нови заявки. Потребителят може да изпълнява следните "команди" за интеракция с приложението:
+ __CREATE име_на_играта брой_цифри__ : създава се игра с посоченето име и се генерира число с броя зададени цифри на случаен принцип
+ __GUESS име_на_играта предположение__ : за посочената игра се прави опит за отгатване на числото
+ __EXIT__ : напускане на играта

Използвайки тези команди, могат да се създадат множество игри и в тях да вземат участие много играчи. След като даден играч познае числото, за него играта приключва и му се дава възможност да създаде нова игра, да участва в друга игра или да напусне приложението.

### Архитектура на приложението

Проектът е създаден чрез umbrella проект, като приложенията в този umbrella проект са 2:
+ __BC__: Приложение, което отговаря за създаването на нови игри, пазейки информация за числото, което трябва да се познае за всяка игра.
+ __BCServer__: Приложение, което приема и обработва заявки от потребителя под формата на команди.

#### BC

За __BC__ се използват __Agent__-и, които пазят числото, което трябва да бъде познато и дават възможност за достъп до него. За целта се използва хеш таблица с ключ __secret__. 

За да имаме достъп до всяка игра посредством името и, създаваме __BC.Registry__, използвайки __GenServer__, което да наблюдава отделните игри. При стартиране на __BC.Registry__-то, инициализараме две нови хеш таблици:
+ В едната пазим името на играта и нейния идентификатор на процес.
+ А в другата уникална референция към наблюдаването на играта (чрез `Process.monitor(pid)`) и името на играта.

По този начин, ако някой процес (игра) приключи изпълнение, ще можем просто да изтрием информацията за играта от __BC.Registry__-то, без това да води до срив на цялото приложение.

За нашето __BC.Registry__ създаваме __BC.Supervisor__ като по този начин, ако __BC.Registry__-то "умре" поради някаква причина, ще може да се създаде ново негово копие, без това да спира работата на приложението. 

Тъй като създаденото __BC.Registry__ създава линк към всяка игра, ако някой от тези процеси crash-не, това ще доведе до срив и на __BC.Registry__-то. Затова създаваме __BC.Game.Supervisor__, за който задаваме опция `restart: :temporary`. По този начин, ако някоя игра crash-не, тя няма да бъде рестартирана. Стратегията за __BC.Game.Supervisor__ е `:simple_one_for_one`, което означава, че ново "дете" на този supervisor ще бъде създадено само при извикване на функцията `start_child/0`.
__BC.Supervisor__ има две "деца":
+ `worker(BC.Registry, [BC.Registry])`
+ `supervisor(BC.Game.Supervisor, [])`

Избираме стратегия `:rest_for_one`за __BC.Supervisor__. Ако някой процес-дете "умре", __BC.Supervisor__ ще рестартира всички процеси-деца, стартирали работата си след въпросто дете. Избираме тази стратегия, тъй като имаме връзка между __BC.Registry__ и __BC.Game__.

#### BCServer

__BCServer__ е създаден с опцията `--sup`, която създава автоматично supervisor за приложението и отбелязва кой да бъде callback модула при стартиране на приложението. За това __BCServer__ приложение, добавяме като dependency създаденото по-рано __BC__ приложение. По този начин __BC__ приложението се стартира автоматично преди стартирането на сървъра. 

СЪздаваме нов __worker__ в нашето supervision tree, който стартира сървъра на порт 4040 при стартиране на приложението. За да може сървърът ни да обработва заявки от различни потребители, създаваме нов __BCServer.TaskSupervisor__, който да създава нови процеси за обработване на различните заявки. 

Стратегията за supervisor-ът на цялото приложение избираме да бъде `:one_for_one`, което означава, че ако някое от "децата" crash-не, само то ще бъде рестартирано. В конкретния случай - ако процесът, приемащ заявките "умре", той ще бъде рестартиран като няма нужда да бъдат рестартирани и процесите, обслужващи заявките. Обратното също е вярно.
