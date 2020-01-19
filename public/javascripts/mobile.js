// Hey there!
// 1/12/2011

var Mobile = {
	data: null,
	fades: [
		{id: 'title', time: 0.5},
		{id: 'main_menu', time: 1.0},
		{id: 'qufoto', time: 2.0}
	],
	width_for_device: {
		phone: 300,
		tablet: 748
	},
	history: [],
	live_bucket: 'images.qufoto.com',
	initialize: function(data, bucket, device_type) {
		this.data = data;
		this.bucket = bucket;
		this.device_type = device_type;
		this.history.push('main');
		this.setupListeners();
		this.display();
	},
	setupListeners: function() {
		document.observe('scroll', this.scroll.bindAsEventListener(this), false);
		document.observe('touchstart', this.touchstart.bindAsEventListener(this), false);
		document.observe('touchmove', this.touchmove.bindAsEventListener(this), false);
		document.observe('touchend', this.touchend.bindAsEventListener(this), false);
	},
	scroll: function() {
		$('back_float').style.marginTop = (document.viewport.getScrollOffsets()[1] + 10) + 'px';
	},
	touchstart: function(e) {},
	touchmove: function(e) {},
	touchend: function(e) {},
	display: function() {
		this.fades.each(function(f) {
			if ($(f.id))
				Element.addClassName.delay(f.time, f.id, 'fadein');
		});
	},
	show: function(page) {
		var last = this.history.last();
		if (last)
			$(last).addClassName('left');
		this.history.push(page);
		$(page).show();
		setTimeout(function(){	
			$(page).removeClassName('right');
		}, 10);
	},
	back: function() {
		document.body.scrollTo(0,0);
		var current = this.history.pop();
		var last = this.history.last();
		
		(function(current, last) {
			$(current).addClassName('right');
			$(last).removeClassName('left');
		}).delay(0.25, current, last);
		
		(function(current) {
			$(current).hide()
		}).delay(0.75, current);
		
		$('back_float').removeClassName('fadein');
	},
	imageUrl: function(id) {
		var parts = this.bucket == this.live_bucket ?
			['http://', this.bucket, '/', id, '_student.jpg']:
			['http://s3.amazonaws.com/', this.bucket, '/', id, '_student.jpg'];
		return parts.join('');
	},
	//imageElement: function(id) {
	//	return new Element('img', {src: this.imageUrl(id)});
	//},
	portfolio: function(id) {
		this.createPortfolio(id);
		this.show('portfolio_' + id);
		$('back_float').addClassName('fadein');
	},
	createPortfolio: function(id) {
		if ($('portfolio_' + id)) return;
		document.body.insert({
			bottom: new Element('div', {
				id: 'portfolio_' + id,
				'class': 'page right'
			})
		});
		this.loadImage.bind(this).delay(0.5, id, 0);
	},
	loadImage: function(portfolio, i) {
		if (i == 0) {
			$('portfolio_' + portfolio).insert({
				bottom: new Element('p', {id: 'p_back_' + portfolio, 'class': 'ul'}).insert({
					bottom: new Element('a', {'class': 'li last', onclick: 'Mobile.back()'}).update('&laquo; back')
				})
			});
		}
		var image = this.data.portfolios[portfolio].images[i];
		var image_obj = new Image();
		image_obj.src = this.imageUrl(image.id);
		image_obj.observe('load', this.loadImage_cb.bind(this, portfolio, i, image, image_obj));
	},
	loadImage_cb: function(portfolio, i, image, image_obj) {
		var canvas = document.createElement('canvas');
		var context = canvas.getContext('2d');
		var max_width = this.width_for_device[this.device_type];
		var scale = image_obj.width <= max_width ? 1.0 : max_width / image_obj.width;
		canvas.width = image_obj.width * scale;
		canvas.height = image_obj.height * scale;
		context.drawImage(image_obj, 0, 0, canvas.width, canvas.height);
		delete image_obj;
		var image_div = new Element('div', {id: 'image_' + portfolio + '_' + i, 'class': 'portfolio'})
			.insert({bottom: canvas})
			.insert({bottom: new Element('p', {'class': 'title'}).update(image.title)})
			.insert({bottom: new Element('p', {'class': 'description'}).update(image.description)})
		$('p_back_' + portfolio).insert({before: image_div});
		Element.addClassName.delay(0.1, image_div, 'fadein');
		if (i < this.data.portfolios[portfolio].images.length - 1) {
			this.loadImage(portfolio, i + 1);
		}
	},
	send: function() {
		var form = $('contact_form');
		var message = form.serialize(true);
		if (message.name.blank() || message.email.blank() || message.body.blank()) {
			alert('Please fill out all fields');
			return;
		}
		form.disable();
		new Ajax.Request('/send_message', {
			parameters: {
				messageName: message.name,
				messageEmail: message.email,
				messageText: message.body
			},
			onSuccess: this.send_cb.bindAsEventListener(this),
			onFailure: this.send_failure.bindAsEventListener(this)
		});
	},
	send_cb: function(transport) {
		if (transport.responseText.match('true')) {
			$('contact_form').reset();
			alert('Sent!');
			this.back();
		}
		else {
			alert('Delivery failure! Check all the fields');
		}
		$('contact_form').enable();
	},
	send_failure: function(transport) {
		alert('Message failed!');
		$('contact_form').enable();
	}
};
