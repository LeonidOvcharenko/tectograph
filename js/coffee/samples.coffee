"use strict";
!(($, win, doc) ->
	$doc = $ doc
	$win = $ win
	
	# system examples
	win.system0 = new S
		root: 'human'
		spirit: new A
			title: 'Дух'
			description: 'высшая способность человека, позволяющая ему стать источником смыслополагания, личностного самоопределения, осмысленного преображения действительности'
		soul: new A
			title: '[Бессмертная] Душа'
			description: 'бессмертная субстанция, в которой выражена божественная природа его личности, дающая начало и обуславливающая жизнь, способности ощущения, мышления, сознания, чувств и воли'
			picture:
				url: 'http://100jelanii.ru/wp-content/uploads/2012/02/1312628438_astralnyi_1.jpg'
				pos: 'below.desc'
				width: 454
				height: 649
		body: new A
			title: '[Физическое] Тело'
			description: 'тело, которым обладают представители всех категорий природы и которое подчиняется законам неорганического мира'
		human: new A
			title: "Человек"
			description: "Взаимосвязанная совокупность интеллектуальной, эмоциональной и физической составляющих"
			picture:
				url: 'http://www.enchantedlearning.com/artists/davinci/gifs/proportions.GIF'
				pos: 'right.desc'
			featured: false
			structure: "list.inline"
			matrix: [
				['spirit', null, null],
				[null, 'soul', null],
				[null, null, 'body']
			]

	win.system1 =
		root: 'human'
		spirit:
			title: 'Дух'
			description: 'высшая способность человека, позволяющая ему стать источником смыслополагания, личностного самоопределения, осмысленного преображения действительности'
		soul:
			title: '[Бессмертная] Душа'
			description: 'бессмертная субстанция, в которой выражена божественная природа его личности, дающая начало и обуславливающая жизнь, способности ощущения, мышления, сознания, чувств и воли'
			picture:
				url: 'http://100jelanii.ru/wp-content/uploads/2012/02/1312628438_astralnyi_1.jpg'
				pos: 'below.desc'
				width: 454
				height: 649
		body:
			title: '[Физическое] Тело'
			description: 'тело, которым обладают представители всех категорий природы и которое подчиняется законам неорганического мира'
		sp2b:
			title: 'a→b'
			description: '...'
		human:
			title: "Человек"
			description: "Взаимосвязанная совокупность интеллектуальной, эмоциональной и физической составляющих"
			picture:
				url: 'http://www.enchantedlearning.com/artists/davinci/gifs/proportions.GIF'
				pos: 'right.desc'
			featured: false
			structure: "graph" # "list.inline"
			matrix: [
				['spirit', null, 'sp2b'],
				['sp2b', 'soul', 'sp2b'],
				['sp2b', null, 'body']
			]
			
	win.system2 = new S
		root: 'virus'
		story: ['virus', 'struct', 'creation', 'being', 'interaction', 'virus']
		virus: new A
			title: 'Ментальный вирус (по И. Ашманову)'
			link:
				url: 'http://roem.ru/2014/08/07/ashmanov104753/'
			description: 'Упорядоченная информационная структура, созданная искусственно с целью захвата власти над умами, способная при передаче в виде информационного сообщения того или иного формата (новость, книга, статья, письмо, ролик, фильм, песня, пр.) захватывать внимание неподготовленного субъекта, превращаться для него в навязчивую идею, подчинять себе мышление, структурировать его и делать субъекта восприимчивым к внешнему управлению.'
			structure: "list.inline"
			matrix: [
				['struct', null, null, null],
				[null, 'creation', null, null],
				[null, null, 'being', null],
				[null, null, null, 'interaction']
			]
		struct: new A
			title: 'Устройство'
			structure: "list.bricks"
			matrix: [
				['target', null, null],
				[null, 'hook', null],
				[null, null, 'delivery']
			]
		being: new A
			title: 'Функционирование'
			structure: "list.bricks"
			matrix: [
				['management', null, 'dummy1', null],
				['dummy5', 'intrusion', null, null],
				[null, 'dummy2', 'reprogramming', null],
				[null, 'dummy3', 'dummy4', 'immunity']
			]
		creation: new A
			title: 'Создание'
			structure: "list.bricks"
			matrix: [
				['stages', null],
				[null, 'owner']
			]
		interaction: new A
			title: 'Взаимодействие с вирусом'
			structure: "list.inline"
			matrix: [
				['desease', null, null],
				[null, 'hygiene', null],
				[null, null, 'resistance']
			]
		intrusion: new A
			title: 'Средства внедрения'
			description: 'воздействие на слабые места читателя, типовые реакции, попытки получить сродство с пользователем, вызвать резонанс – для этого используются неуверенность, страхи, шаблоны, родительские знания по Берну, архетипы, высказывания, которые всякий может отнести к себе. Многократные повторения сообщения являются характерным признаком модуля внедрения, хотя встречаются и не каждый раз. Отключение рационального мышления — главный результат этой раскачки архетипов, который позволяет внедриться в сознание.'
			picture:
				url: 'http://fomuvi.ru/wp-content/uploads/2010/07/%D0%B2%D0%BD%D0%B5%D0%B4%D1%80%D0%B5%D0%BD%D0%B8%D0%B5-%D1%87%D0%B8%D0%BF%D0%B0-%D0%B2-%D0%BC%D0%BE%D0%B7%D0%B3-%D1%87%D0%B5%D0%BB%D0%BE%D0%B2%D0%B5%D0%BA%D0%B0.jpg'
				pos: 'above.desc'
				width: 400
				height: 306
		reprogramming: new A
			title: 'Средства перепрошивки (перепрограммирования)'
			description: 'новая шокирующая правда, разоблачение общеизвестного, сообщение секретов, шоковые новости, вы не знали, вас обманывали, теперь вы узнаете правду, предсказание будущего, обещание награды: денег, счастья, здоровья и т.п. Для «перепрошивки» у вируса должен быть набор «фактов» и «ценностей» для замены тех фактов и ценностей, которые он выбивает из мозга заражаемого.'
			picture:
				url: 'http://dev.by/ckeditor_assets/pictures/5625/content_ibm_human_brain.jpg'
				pos: 'left.desc'
				width: 400
				height: 225
		stages: new A
			title: 'Процесс'
			structure: 'list.bricks'
			matrix: [
				['stage1', null, null, null],
				[null, 'stage2', null, null],
				[null, null, 'stage3', null],
				[null, null, null, 'stage4']
			]
		dummy1: new A
			description: 'связь'
		dummy2: new A
			description: 'связь'
		dummy3: new A
			description: 'связь'
		dummy4: new A
			description: 'связь'
		dummy5: new A
			description: 'связь'
		stage1: new A
			title: 'Анализ и выбор аудитории'
		stage2: new A
			title: 'Генерация и проверка'
		stage3: new A
			title: 'Вброс (посев)'
		stage4: new A
			title: 'Эксплуатация'
		owner: new A
			title: 'Кто разрабатывает'
			structure: 'list.stack'
			matrix: [
				['private', null],
				[null, 'gov']
			]
		private: new A
			title: 'Частные вирусы'
			description: 'мода, рекламщики, табачники, сектанты, мошенники, пиарщики, бизнес-тренеры и продавцы средств от похудения'
			picture:
				url: 'http://www.k-istine.ru/images/sects/mosk/mosk-16.jpg'
				pos: 'below.desc'
				width: 580
				height: 390
		gov: new A
			title: 'Государственные (боевые) вирусы'
			description: 'места вброса: социальные сети, блоги, новостные тизерные сети; сети распространения: СМИ'
		immunity: new A
			title: 'Средства защиты от антивирусов и других вирусов'
			description: 'Указание на врагов, разоблачение их «лжи» заранее, набор аргументов на будущее, «не верьте, если вам скажут, что», оптовое принижение и расчеловечивание оппонентов. Алгоритмы защиты должны быть не сложнее двухходовки.'
		target: new A
			title: 'Цель'
			description: 'к которой побуждается заражённый реципиент. Это обычно некоторое действие плюс дальнейшее распространение'
		hook: new A
			title: 'Крючок'
			description: 'средства захвата внимания'
			picture:
				url: 'http://pbs.twimg.com/profile_images/1844208158/hook_logo.png'
				pos: 'below.desc'
		delivery: new A
			title: 'Средства доставки'
			description: 'вброс через ботов, фейковые аккаунты, виртуальных пользователей, лидеров мнений, многослойные структуры и т.п.'
			picture:
				url: 'http://2.bp.blogspot.com/-EdNQf441qKI/U0uJtDo8D4I/AAAAAAAAACw/JJuHqdT_lLk/s1600/header.png'
				pos: 'below.desc'
				width: 750
				height: 250
		management: new A
			title: 'Управление захваченным объектом'
			description: 'инструкции по выполнению разных действий - пойти на опрос проголосовать, подписать петицию, скачать софт для DDoS, забомбить сайт или госучреждение массовыми комментами или массовой атакой, выйти с утра на митинг/майдан, перевести деньги и т.п. + Инструкции по дальнейшему распространению.'
		desease: new A
			title: 'Болезнь'
			structure: "list.bricks"
			matrix: [
				['ideafix', null, null],
				[null, 'dofamin', null],
				[null, null, 'media']
			]
		ideafix: new A
			title: 'Навязчивая идея'
		dofamin: new A
			title: 'Дофаминовые циклы'
		media: new A
			title: 'Медийная наркомания'
		hygiene: new A
			title: 'Гигиена'
			description: 'Помнить, что поток новостей и постов – заведомо мутный, загрязнённый. уметь распознавать наиболее характерные признаки ментального вируса искать и накапливать так называемые чистые источники'
		resistance: new A
			title: 'Системное противодействие'
			structure: "list.bricks"
			matrix: [
				['clear_sources', null, null, null],
				[null, 'real_things', null, null],
				[null, null, 'truth', null],
				[null, null, null, 'flora']
			]
		clear_sources: new A
			title: 'создавать чистые источники'
			description: 'места без неправды'
		real_things: new A
			title: 'генерировать реальные события'
		truth: new A
			title: 'подробно и терпеливо объяснять правду'
			description: 'использовать силу повторения'
		flora: new A
			title: 'создавать свою здоровую флору'
			description: 'учебники, книги, фильмы, праздники, идеология'
			
	win.system3 = new S
		root: 'iface'
		iface: new A
			title: 'Интерфейс пользователя'
			description: 'Расширенная модель человеко-компьютерного взаимодействия.'
			structure: "graph"
			matrix: [
				['human', 'input'],
				['output', 'machine']
			]
		human: new A
			title: 'Человек'
			structure: "graph"
			matrix: [
				['goals', 'dummy1', 'dummy2'],
				['dummy4', 'mmodel', 'dummy3'],
				['dummy5', 'dummy6', 'habits']
			]
		machine: new A
			title: 'Компьютер'
			description: 'Совокупность аппаратного и программного обеспечения'
			structure: "matrix"
			matrix: [
				['hardware', null],
				[null, 'software']
			]
		dummy1: new A
			description: 'связь'
		dummy2: new A
			description: 'связь'
		dummy3: new A
			description: 'связь'
		dummy4: new A
			description: 'связь'
		dummy5: new A
			description: 'связь'
		dummy6: new A
			description: 'связь'
		goals: new A
			title: 'Цели'
		mmodel: new A
			title: 'Ментальная модель'
			description: 'Способ понимания механизма работы компьютера, существующий в уме человека и направляющий его действия.'
		habits: new A
			title: 'Навыки'
			description: 'Доведенные до автоматизма действия по взаимодействию с компьютером.'
		input: new A
			title: 'Ввод информации/команд'
			description: 'множество всевозможных устройств для контроля состояния человека — кнопки, переключатели, потенциометры, датчики положения и движения, сервоприводы, жесты лицом и руками, даже съём мозговой активности пользователя.'
		output: new A
			title: 'Вывод информации'
			description: 'весь доступный диапазон воздействий на организм человека (зрительных, слуховых, тактильных, обонятельных и тд.) — экраны (дисплеи, проекторы) и лампочки, динамики, зуммеры и сирены, вибромоторы и тд. и тп.'
		software: new A
			title: 'Программное обеспечение'
			description: 'софт'
		hardware: new A
			title: 'Аппаратное обеспечение'
			description: 'хард'
			
	win.system4 = new S
		root: 'progcycl'
		progcycl: new A
			title: 'Цикл программирования'
			structure: 'graph'
			matrix: [
				['analysis', 'link', null],
				[null, 'design', 'link'],
				['link', null, 'usage']
			]
		analysis: new A
			title: 'Анализ'
			structure: 'list.stack'
			matrix: [
				['s1', null, null],
				[null, 's2', null],
				[null, null, 's3']
			]
		design: new A
			title: 'Конструирование'
			structure: 'list.stack'
			matrix: [
				['s4', null, null],
				[null, 's5', null],
				[null, null, 's6']
			]
		usage: new A
			title: 'Использование'
			structure: 'list.stack'
			matrix: [
				['s7', null, null],
				[null, 's8', null],
				[null, null, 's9']
			]
		s1: new A
			title: 'Установка требований и ограничений'
		s2: new A
			title: 'Построение концептуальной модели решения'
		s3: new A
			title: 'Оценка цены/графика работ/производительности'
		s4: new A
			title: 'Предварительная разработка'
		s5: new A
			title: 'Детальная проработка'
		s6: new A
			title: 'Реализация'
		s7: new A
			title: 'Оптимизация'
		s8: new A
			title: 'Устранение ошибок и отладка'
		s9: new A
			title: 'Поддержка'
		link: new A
			title: ' '

	win.system5 = new S
		root: 'copydetect'
		copydetect: new A
			title: 'Copy detecting'
			structure: 'graph'
			# layout:
			#	graph: ...
			#	matrix: ...
			matrix: [
				['s1', 'l1', 'l2', null, null, null, null, null],
				[null, 's2', null, null, null, null, null, null],
				[null, null, 's3', 'l3', 'l4', null, null, null],
				[null, null, null, 's4', null, 'l7', null, null],
				[null, null, null, null, 's5', 'l5', null, null],
				[null, null, null, null, 'l6', 's6', null, null],
				[null, null, null, null, null, null, 's7', null],
				[null, null, null, null, null, null, null, 's8']
			]
		s1: new A
			title: 'New blocks queue'
			featured: true
			link:
				url: 'http://vk.com'
		s2: new A
			title: 'monitoring threads'
		s3: new A
			title: 'TextFingerPrint_worker'
			description: '- що робити, коли втрачається конект до Монго? треба потестити, як відновлювати  - може варто буде робити сліп між задачами, щоб не сильно загружався проц (певно сліп перед початком обробки блока, але тільки якщо перед цим щойно був блок)'
			link:
				url: 'http://google.com.ua?q=TextFingerPrint_worker'
		s4: new A
			title: 'New fp queue'
		s5: new A
			# title: 'DataBase'
			picture:
				url: 'https://cdn1.iconfinder.com/data/icons/windows-8-metro-style/512/database.png'
				pos: 'right.desc'
				width: 512
				height: 512
			structure: 'list.inline'
			matrix: [
				['fp', null],
				[null, 'res']
			]
		s6: new A
			title: 'CopyDetector_worker'
			link:
				url: 'http://google.com.ua?q=CopyDetector_worker'
		s7: new A
			title: 'Delivery'
			description: 'отримати список різних сайтів, на які підписаний користувач (page_id)'
		s8: new A
			title: 'Розглядаємо блок, який попав у доставку'
			description: '- не розпізнавати сторінку з лінка новини, бо це може бути лінк на сторонній сайт, який взагалі не моніториться  - якщо блок !is_copy_of - доставляємо  - якщо блок має has_copies - додаємо циферку до тайтла  - але при рахуванні циферки не нараховуємо +1, якщо копія знаходиться на тому ж сайті, що й ця (як на фінансах є, що лінки різні, але все решта однакове)  ...'
		l1: new A
			title: '.'
			description: 'publish with :persistent => true  Block data: - url - path - title - short - ...'
		l2: new A
			title: ':'
			description: 'channel.prefetch(1)  queue :durable => true'
		l3: new A
			title: '--'
			description: 'text fingerprint (signature) for all the elements (title, short...)'
		l4: new A
			title: '-----'
			description: '...'	
		l5: new A
			description: 'На початку роботи раз підгрузити всі text fp за тиждень'
		l6: new A
			title: 'nya'
			description: 'Записати результати звірки у спеціальну колекцію + новий запис: is copy (path to ori), або просто запис, якщо не є дублем ~ змінити запис оригінала: has copy (this path)'
		l7: new A
			title: '1'
			description: 'Block data + fp'
		fp: new A
			title: 'fingerprints'
		res: new A
			title: 'CopyDetector_results'
			featured: true
			description: '- _id (path) (indexed)  - page_id  - link    - is_copy_of: [  { _id: of_ori, percent: % },  { _id: of_ori, percent: % }  ] or nil    - has_copies: [    path, path]'
	
	win.system6 = new S
		"root":   "human"
		"human":  new A {"title":"uKeeper","description":"Дозволяє перетворювати лінк на збережену статтю.\nМагія очищення сторінки від зайвого.","picture":{"url":"","pos":"","width":"16","height":"16"},"featured":false,"structure":"list.inline","matrix":[["i24279",null],[null,"i39913"]],"id":"human","link":{url:"http://ukeeper.com/",pos:'title'}}
		"i24279": new A {"title":"Bookmarklet","id":"i24279","link":{"url":"","pos":"title"},"description":"Працює з поточною сторінкою","picture":{"url":"","pos":"","width":""},"structure":null,"matrix":null}
		"i39913": new A {"title":"drops@ukeeper.com","id":"i39913","link":{"url":"","pos":"title"},"description":"Можна висилати лінки на цей емейл.","picture":{"url":"","pos":"","width":""},"structure":"graph","matrix":[["i2843","i58861",null],[null,"i4381","i84147"],[null,null,"i60050"]]}
		"i2843":  new A {"title":"From Email","id":"i2843","link":{"url":"","pos":"title"},"description":"Емейл з якого приймаються листи","picture":{"url":"","pos":"","width":""},"structure":null,"matrix":null}
		"i60050": new A {"title":"Forward Email","id":"i60050","link":{"url":"","pos":"title"},"description":"Емейл на який переслиються готові статті","picture":{"url":"","pos":"","width":""},"structure":"list.inline","matrix":[["i84181",null],[null,"i27974"]]}
		"i84181": new A {"title":"Evernote","id":"i84181","link":{"url":"","pos":"title"},"description":"Збереження в еверноті","picture":{"url":"","pos":"","width":""},"structure":"list.stack","matrix":[["i60054"]]}
		"i60054": new A {"title":"Теги","id":"i60054","link":{"url":"","pos":"title"},"description":"#tag додавати в кінці сабджекта","picture":{"url":"","pos":"","width":""},"structure":null,"matrix":null}
		"i27974": new A {"title":"Kindle","id":"i27974","link":{"url":"","pos":"title"},"description":"Воно розуміє, що це Кіндл і посилає статтю в аттачменті!","picture":{"url":"","pos":"","width":""},"structure":null,"matrix":null}
		"i4381":  new A {"title":"Features","id":"i4381","link":{"url":"","pos":"title"},"description":"","picture":{"url":"","pos":"","width":""},"structure":"list.stack","matrix":[["i63579",null],[null,"i75804"]]}
		"i63579": new A {"title":"Force my title","id":"i63579","link":{"url":"","pos":"title"},"description":"Додати \"!\" перед subject","picture":{"url":"","pos":"","width":""},"structure":null,"matrix":null}
		"i75804": new A {"title":"Make PDF","id":"i75804","link":{"url":"","pos":"title"},"description":"Додати %p у subj","picture":{"url":"","pos":"","width":""},"structure":null,"matrix":null}
		"i58861": new A {"title":"from→","id":"i58861","link":{"url":"","pos":"title"},"description":"","picture":{"url":"","pos":"","width":""},"structure":null,"matrix":null}
		"i84147": new A {"title":"→email","id":"i84147","link":{"url":"","pos":"title"},"description":"","picture":{"url":"","pos":"","width":""},"structure":null,"matrix":null}

	win.system7 = new S
		"root":     "iface"
		"iface":    new A {"title":"Интерфейс пользователя","description":"Расширенная модель человеко-компьютерного взаимодействия.","structure":"graph","matrix":[["human","input"],["output","machine"]],"id":"iface","link":"","picture":{"url":"","pos":"","width":"","scale":1}}
		"human":    new A {"title":"Человек","structure":"graph","matrix":[["goals","dummy1","dummy2"],["dummy4","mmodel","dummy3"],["dummy5","dummy6","habits"]],"id":"human"}
		"machine":  new A {"title":"Компьютер","description":"Совокупность аппаратного и программного обеспечения","structure":"matrix","matrix":[["hardware",null],[null,"software"]],"id":"machine"}
		"dummy1":   new A {"description":"связь","id":"dummy1"}
		"dummy2":   new A {"description":"связь","id":"dummy2"}
		"dummy3":   new A {"description":"связь","id":"dummy3"}
		"dummy4":   new A {"description":"связь","id":"dummy4"}
		"dummy5":   new A {"description":"связь","id":"dummy5"}
		"dummy6":   new A {"description":"связь","id":"dummy6"}
		"goals":    new A {"title":"Цели","id":"goals","link":"","description":"","picture":{"url":"","pos":"","width":"","scale":1},"structure":null,"matrix":null}
		"mmodel":   new A {"title":"Ментальная модель","description":"Способ понимания механизма работы компьютера, существующий в уме человека и направляющий его действия.","id":"mmodel","link":"","picture":{"url":"","pos":"","width":"","scale":1},"structure":null,"matrix":null}
		"habits":   new A {"title":"Навыки","description":"Доведенные до автоматизма действия по взаимодействию с компьютером.","id":"habits","link":"","picture":{"url":"","pos":"","width":"","scale":1},"structure":null,"matrix":null}
		"input":    new A {"title":"Ввод информации/команд","description":"множество всевозможных устройств для контроля состояния человека — кнопки, переключатели, потенциометры, датчики положения и движения, сервоприводы, жесты лицом и руками, даже съём мозговой активности пользователя.","id":"input","link":"","picture":{"url":"","pos":"","width":"","scale":1},"structure":null,"matrix":null}
		"output":   new A {"title":"Вывод информации","description":"весь доступный диапазон воздействий на организм человека (зрительных, слуховых, тактильных, обонятельных и тд.) — экраны (дисплеи, проекторы) и лампочки, динамики, зуммеры и сирены, вибромоторы и тд. и тп.","id":"output","link":"","picture":{"url":"","pos":"","width":"","scale":1},"structure":null,"matrix":null}
		"software": new A {"title":"Программное обеспечение","description":"софт","id":"software"}
		"hardware": new A {"title":"Аппаратное обеспечение","description":"хард","id":"hardware"}

	win.empty_system = new S
		"root":     "i0000"
		"i0000":    new A {"title":"Empty system","description":"with no description"}

)(jQuery, window, document)

###

po.dblclick = function() {
  var dblclick = {},
      zoom = "mouse",
      map,
      container;

  function handle(e) {
    var z = map.zoom();
    if (e.shiftKey) z = Math.ceil(z) - z - 1;
    else z = 1 - z + Math.floor(z);
    zoom === "mouse" ? map.zoomBy(z, map.mouse(e)) : map.zoomBy(z);
  }

  dblclick.zoom = function(x) {
    if (!arguments.length) return zoom;
    zoom = x;
    return dblclick;
  };

  dblclick.map = function(x) {
    if (!arguments.length) return map;
    if (map) {
      container.removeEventListener("dblclick", handle, false);
      container = null;
    }
    if (map = x) {
      container = map.container();
      container.addEventListener("dblclick", handle, false);
    }
    return dblclick;
  };

  return dblclick;
};

po.arrow = function() {
  var arrow = {},
      key = {left: 0, right: 0, up: 0, down: 0},
      last = 0,
      repeatTimer,
      repeatDelay = 250,
      repeatInterval = 50,
      speed = 16,
      map,
      parent;

  function keydown(e) {
    if (e.ctrlKey || e.altKey || e.metaKey) return;
    var now = Date.now(), dx = 0, dy = 0;
    switch (e.keyCode) {
      case 37: {
        if (!key.left) {
          last = now;
          key.left = 1;
          if (!key.right) dx = speed;
        }
        break;
      }
      case 39: {
        if (!key.right) {
          last = now;
          key.right = 1;
          if (!key.left) dx = -speed;
        }
        break;
      }
      case 38: {
        if (!key.up) {
          last = now;
          key.up = 1;
          if (!key.down) dy = speed;
        }
        break;
      }
      case 40: {
        if (!key.down) {
          last = now;
          key.down = 1;
          if (!key.up) dy = -speed;
        }
        break;
      }
      default: return;
    }
    if (dx || dy) map.panBy({x: dx, y: dy});
    if (!repeatTimer && (key.left | key.right | key.up | key.down)) {
      repeatTimer = setInterval(repeat, repeatInterval);
    }
    e.preventDefault();
  }

  function keyup(e) {
    last = Date.now();
    switch (e.keyCode) {
      case 37: key.left = 0; break;
      case 39: key.right = 0; break;
      case 38: key.up = 0; break;
      case 40: key.down = 0; break;
      default: return;
    }
    if (repeatTimer && !(key.left | key.right | key.up | key.down)) {
      repeatTimer = clearInterval(repeatTimer);
    }
    e.preventDefault();
  }

  function keypress(e) {
    switch (e.charCode) {
      case 45: case 95: map.zoom(Math.ceil(map.zoom()) - 1); break; // - _
      case 43: case 61: map.zoom(Math.floor(map.zoom()) + 1); break; // = +
      default: return;
    }
    e.preventDefault();
  }

  function repeat() {
    if (!map) return;
    if (Date.now() < last + repeatDelay) return;
    var dx = (key.left - key.right) * speed,
        dy = (key.up - key.down) * speed;
    if (dx || dy) map.panBy({x: dx, y: dy});
  }

  arrow.map = function(x) {
    if (!arguments.length) return map;
    if (map) {
      parent.removeEventListener("keypress", keypress, false);
      parent.removeEventListener("keydown", keydown, false);
      parent.removeEventListener("keyup", keyup, false);
      parent = null;
    }
    if (map = x) {
      parent = map.focusableParent();
      parent.addEventListener("keypress", keypress, false);
      parent.addEventListener("keydown", keydown, false);
      parent.addEventListener("keyup", keyup, false);
    }
    return arrow;
  };

  arrow.speed = function(x) {
    if (!arguments.length) return speed;
    speed = x;
    return arrow;
  };

  return arrow;
};
po.hash = function() {
  var hash = {},
      s0, // cached location.hash
      lat = 90 - 1e-8, // allowable latitude range
      map;

  var parser = function(map, s) {
    var args = s.split("/").map(Number);
    if (args.length < 3 || args.some(isNaN)) return true; // replace bogus hash
    else {
      var size = map.size();
      map.zoomBy(args[0] - map.zoom(),
          {x: size.x / 2, y: size.y / 2},
          {lat: Math.min(lat, Math.max(-lat, args[1])), lon: args[2]});
    }
  };

  var formatter = function(map) {
    var center = map.center(),
        zoom = map.zoom(),
        precision = Math.max(0, Math.ceil(Math.log(zoom) / Math.LN2));
    return "#" + zoom.toFixed(2)
             + "/" + center.lat.toFixed(precision)
             + "/" + center.lon.toFixed(precision);
  };

  function move() {
    var s1 = formatter(map);
    if (s0 !== s1) location.replace(s0 = s1); // don't recenter the map!
  }

  function hashchange() {
    if (location.hash === s0) return; // ignore spurious hashchange events
    if (parser(map, (s0 = location.hash).substring(1)))
      move(); // replace bogus hash
  }

  hash.map = function(x) {
    if (!arguments.length) return map;
    if (map) {
      map.off("move", move);
      window.removeEventListener("hashchange", hashchange, false);
    }
    if (map = x) {
      map.on("move", move);
      window.addEventListener("hashchange", hashchange, false);
      location.hash ? hashchange() : move();
    }
    return hash;
  };

  hash.parser = function(x) {
    if (!arguments.length) return parser;
    parser = x;
    return hash;
  };

  hash.formatter = function(x) {
    if (!arguments.length) return formatter;
    formatter = x;
    return hash;
  };

  return hash;
};
po.touch = function() {
  var touch = {},
      map,
      container,
      rotate = false,
      last = 0,
      zoom,
      angle,
      locations = {}; // touch identifier -> location

  window.addEventListener("touchmove", touchmove, false);

  function touchstart(e) {
    var i = -1,
        n = e.touches.length,
        t = Date.now();

    // doubletap detection
    if ((n == 1) && (t - last < 300)) {
      var z = map.zoom();
      map.zoomBy(1 - z + Math.floor(z), map.mouse(e.touches[0]));
      e.preventDefault();
    }
    last = t;

    // store original zoom & touch locations
    zoom = map.zoom();
    angle = map.angle();
    while (++i < n) {
      t = e.touches[i];
      locations[t.identifier] = map.pointLocation(map.mouse(t));
    }
  }

  function touchmove(e) {
    switch (e.touches.length) {
      case 1: { // single-touch pan
        var t0 = e.touches[0];
        map.zoomBy(0, map.mouse(t0), locations[t0.identifier]);
        e.preventDefault();
        break;
      }
      case 2: { // double-touch pan + zoom + rotate
        var t0 = e.touches[0],
            t1 = e.touches[1],
            p0 = map.mouse(t0),
            p1 = map.mouse(t1),
            p2 = {x: (p0.x + p1.x) / 2, y: (p0.y + p1.y) / 2}, // center point
            c0 = po.map.locationCoordinate(locations[t0.identifier]),
            c1 = po.map.locationCoordinate(locations[t1.identifier]),
            c2 = {row: (c0.row + c1.row) / 2, column: (c0.column + c1.column) / 2, zoom: 0},
            l2 = po.map.coordinateLocation(c2); // center location
        map.zoomBy(Math.log(e.scale) / Math.LN2 + zoom - map.zoom(), p2, l2);
        if (rotate) map.angle(e.rotation / 180 * Math.PI + angle);
        e.preventDefault();
        break;
      }
    }
  }

  touch.rotate = function(x) {
    if (!arguments.length) return rotate;
    rotate = x;
    return touch;
  };

  touch.map = function(x) {
    if (!arguments.length) return map;
    if (map) {
      container.removeEventListener("touchstart", touchstart, false);
      container = null;
    }
    if (map = x) {
      container = map.container();
      container.addEventListener("touchstart", touchstart, false);
    }
    return touch;
  };

  return touch;
};
// Default map controls.
po.interact = function() {
  var interact = {},
      drag = po.drag(),
      wheel = po.wheel(),
      dblclick = po.dblclick(),
      touch = po.touch(),
      arrow = po.arrow();

  interact.map = function(x) {
    drag.map(x);
    wheel.map(x);
    dblclick.map(x);
    touch.map(x);
    arrow.map(x);
    return interact;
  };

  return interact;
};
po.compass = function() {
  var compass = {},
      g = po.svg("g"),
      ticks = {},
      r = 30,
      speed = 16,
      last = 0,
      repeatDelay = 250,
      repeatInterval = 50,
      position = "top-left", // top-left, top-right, bottom-left, bottom-right
      zoomStyle = "small", // none, small, big
      zoomContainer,
      panStyle = "small", // none, small
      panTimer,
      panDirection,
      panContainer,
      drag,
      dragRect = po.svg("rect"),
      map,
      container,
      window;

  g.setAttribute("class", "compass");
  dragRect.setAttribute("class", "back fore");
  dragRect.setAttribute("pointer-events", "none");
  dragRect.setAttribute("display", "none");

  function panStart(e) {
    g.setAttribute("class", "compass active");
    if (!panTimer) panTimer = setInterval(panRepeat, repeatInterval);
    if (panDirection) map.panBy(panDirection);
    last = Date.now();
    return cancel(e);
  }

  function panRepeat() {
    if (panDirection && (Date.now() > last + repeatDelay)) {
      map.panBy(panDirection);
    }
  }

  function mousedown(e) {
    if (e.shiftKey) {
      drag = {x0: map.mouse(e)};
      map.focusableParent().focus();
      return cancel(e);
    }
  }

  function mousemove(e) {
    if (!drag) return;
    drag.x1 = map.mouse(e);
    dragRect.setAttribute("x", Math.min(drag.x0.x, drag.x1.x));
    dragRect.setAttribute("y", Math.min(drag.x0.y, drag.x1.y));
    dragRect.setAttribute("width", Math.abs(drag.x0.x - drag.x1.x));
    dragRect.setAttribute("height", Math.abs(drag.x0.y - drag.x1.y));
    dragRect.removeAttribute("display");
  }

  function mouseup(e) {
    g.setAttribute("class", "compass");
    if (drag) {
      if (drag.x1) {
        map.extent([
          map.pointLocation({
            x: Math.min(drag.x0.x, drag.x1.x),
            y: Math.max(drag.x0.y, drag.x1.y)
          }),
          map.pointLocation({
            x: Math.max(drag.x0.x, drag.x1.x),
            y: Math.min(drag.x0.y, drag.x1.y)
          })
        ]);
        dragRect.setAttribute("display", "none");
      }
      drag = null;
    }
    if (panTimer) {
      clearInterval(panTimer);
      panTimer = 0;
    }
  }

  function panBy(x) {
    return function() {
      x ? this.setAttribute("class", "active") : this.removeAttribute("class");
      panDirection = x;
    };
  }

  function zoomBy(x) {
    return function(e) {
      g.setAttribute("class", "compass active");
      var z = map.zoom();
      map.zoom(x < 0 ? Math.ceil(z) - 1 : Math.floor(z) + 1);
      return cancel(e);
    };
  }

  function zoomTo(x) {
    return function(e) {
      map.zoom(x);
      return cancel(e);
    };
  }

  function zoomOver() {
    this.setAttribute("class", "active");
  }

  function zoomOut() {
    this.removeAttribute("class");
  }

  function cancel(e) {
    e.stopPropagation();
    e.preventDefault();
    return false;
  }

  function pan(by) {
    var x = Math.SQRT1_2 * r,
        y = r * .7,
        z = r * .2,
        g = po.svg("g"),
        dir = g.appendChild(po.svg("path")),
        chv = g.appendChild(po.svg("path"));
    dir.setAttribute("class", "direction");
    dir.setAttribute("pointer-events", "all");
    dir.setAttribute("d", "M0,0L" + x + "," + x + "A" + r + "," + r + " 0 0,1 " + -x + "," + x + "Z");
    chv.setAttribute("class", "chevron");
    chv.setAttribute("d", "M" + z + "," + (y - z) + "L0," + y + " " + -z + "," + (y - z));
    chv.setAttribute("pointer-events", "none");
    g.addEventListener("mousedown", panStart, false);
    g.addEventListener("mouseover", panBy(by), false);
    g.addEventListener("mouseout", panBy(null), false);
    g.addEventListener("dblclick", cancel, false);
    return g;
  }

  function zoom(by) {
    var x = r * .4,
        y = x / 2,
        g = po.svg("g"),
        back = g.appendChild(po.svg("path")),
        dire = g.appendChild(po.svg("path")),
        chev = g.appendChild(po.svg("path")),
        fore = g.appendChild(po.svg("path"));
    back.setAttribute("class", "back");
    back.setAttribute("d", "M" + -x + ",0V" + -x + "A" + x + "," + x + " 0 1,1 " + x + "," + -x + "V0Z");
    dire.setAttribute("class", "direction");
    dire.setAttribute("d", back.getAttribute("d"));
    chev.setAttribute("class", "chevron");
    chev.setAttribute("d", "M" + -y + "," + -x + "H" + y + (by > 0 ? "M0," + (-x - y) + "V" + -y : ""));
    fore.setAttribute("class", "fore");
    fore.setAttribute("fill", "none");
    fore.setAttribute("d", back.getAttribute("d"));
    g.addEventListener("mousedown", zoomBy(by), false);
    g.addEventListener("mouseover", zoomOver, false);
    g.addEventListener("mouseout", zoomOut, false);
    g.addEventListener("dblclick", cancel, false);
    return g;
  }

  function tick(i) {
    var x = r * .2,
        y = r * .4,
        g = po.svg("g"),
        back = g.appendChild(po.svg("rect")),
        chev = g.appendChild(po.svg("path"));
    back.setAttribute("pointer-events", "all");
    back.setAttribute("fill", "none");
    back.setAttribute("x", -y);
    back.setAttribute("y", -.75 * y);
    back.setAttribute("width", 2 * y);
    back.setAttribute("height", 1.5 * y);
    chev.setAttribute("class", "chevron");
    chev.setAttribute("d", "M" + -x + ",0H" + x);
    g.addEventListener("mousedown", zoomTo(i), false);
    g.addEventListener("dblclick", cancel, false);
    return g;
  }

  function move() {
    var x = r + 6, y = x, size = map.size();
    switch (position) {
      case "top-left": break;
      case "top-right": x = size.x - x; break;
      case "bottom-left": y = size.y - y; break;
      case "bottom-right": x = size.x - x; y = size.y - y; break;
    }
    g.setAttribute("transform", "translate(" + x + "," + y + ")");
    dragRect.setAttribute("transform", "translate(" + -x + "," + -y + ")");
    for (var i in ticks) {
      i == map.zoom()
          ? ticks[i].setAttribute("class", "active")
          : ticks[i].removeAttribute("class");
    }
  }

  function draw() {
    while (g.lastChild) g.removeChild(g.lastChild);

    g.appendChild(dragRect);

    if (panStyle != "none") {
      panContainer = g.appendChild(po.svg("g"));
      panContainer.setAttribute("class", "pan");

      var back = panContainer.appendChild(po.svg("circle"));
      back.setAttribute("class", "back");
      back.setAttribute("r", r);

      var s = panContainer.appendChild(pan({x: 0, y: -speed}));
      s.setAttribute("transform", "rotate(0)");

      var w = panContainer.appendChild(pan({x: speed, y: 0}));
      w.setAttribute("transform", "rotate(90)");

      var n = panContainer.appendChild(pan({x: 0, y: speed}));
      n.setAttribute("transform", "rotate(180)");

      var e = panContainer.appendChild(pan({x: -speed, y: 0}));
      e.setAttribute("transform", "rotate(270)");

      var fore = panContainer.appendChild(po.svg("circle"));
      fore.setAttribute("fill", "none");
      fore.setAttribute("class", "fore");
      fore.setAttribute("r", r);
    } else {
      panContainer = null;
    }

    if (zoomStyle != "none") {
      zoomContainer = g.appendChild(po.svg("g"));
      zoomContainer.setAttribute("class", "zoom");

      var j = -.5;
      if (zoomStyle == "big") {
        ticks = {};
        for (var i = map.zoomRange()[0], j = 0; i <= map.zoomRange()[1]; i++, j++) {
          (ticks[i] = zoomContainer.appendChild(tick(i)))
              .setAttribute("transform", "translate(0," + (-(j + .75) * r * .4) + ")");
        }
      }

      var p = panStyle == "none" ? .4 : 2;
      zoomContainer.setAttribute("transform", "translate(0," + r * (/^top-/.test(position) ? (p + (j + .5) * .4) : -p) + ")");
      zoomContainer.appendChild(zoom(+1)).setAttribute("transform", "translate(0," + (-(j + .5) * r * .4) + ")");
      zoomContainer.appendChild(zoom(-1)).setAttribute("transform", "scale(-1)");
    } else {
      zoomContainer = null;
    }

    move();
  }

  compass.radius = function(x) {
    if (!arguments.length) return r;
    r = x;
    if (map) draw();
    return compass;
  };

  compass.speed = function(x) {
    if (!arguments.length) return r;
    speed = x;
    return compass;
  };

  compass.position = function(x) {
    if (!arguments.length) return position;
    position = x;
    if (map) draw();
    return compass;
  };

  compass.pan = function(x) {
    if (!arguments.length) return panStyle;
    panStyle = x;
    if (map) draw();
    return compass;
  };

  compass.zoom = function(x) {
    if (!arguments.length) return zoomStyle;
    zoomStyle = x;
    if (map) draw();
    return compass;
  };

  compass.map = function(x) {
    if (!arguments.length) return map;
    if (map) {
      container.removeEventListener("mousedown", mousedown, false);
      container.removeChild(g);
      container = null;
      window.removeEventListener("mousemove", mousemove, false);
      window.removeEventListener("mouseup", mouseup, false);
      window = null;
      map.off("move", move).off("resize", move);
    }
    if (map = x) {
      container = map.container();
      container.appendChild(g);
      container.addEventListener("mousedown", mousedown, false);
      window = container.ownerDocument.defaultView;
      window.addEventListener("mousemove", mousemove, false);
      window.addEventListener("mouseup", mouseup, false);
      map.on("move", move).on("resize", move);
      draw();
    }
    return compass;
  };

  return compass;
};


function ZoomWheel(e)
{
	if (typeof e == 'undefined') e = window.event;

	if (typeof e.wheelDelta != 'undefined')
	{
		if (e.wheelDelta > 0)
			ZoomIt(1.2);
		else if (e.wheelDelta < 0)
			ZoomIt(0.833333333);
	}
	else if (typeof e.detail != 'undefined')
	{
		if (e.detail < 0)
			ZoomIt(1.2);
		else if (e.detail > 0)
			ZoomIt(0.833333333);
	}

	return CancelEvent(e);
}

###
###
FIXES:
	description: ' '
	title: ' ' → fix width
###