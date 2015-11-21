window.i18n = ->
	Ember.I18n.translations =
	# russian
		measures:
			items_per_day: ' нов./сут.'
			minutes: '&nbsp;мин.'
		subs:
			title: 'Подписки'
			add: 'Добавить подписку'
			search:
				words: 'Тема, адрес сайта или потока'

	# ukrainian
	###
		subs:
			search:
				words: 'Тема, адреса сайта або потоку'
				examples: 'Приклади для пошуку:'
				popular: 'Популярне:'
			streams:
				title:
					one: 'One Follower'
					other: 'All {{count}} Followers'
	###
			