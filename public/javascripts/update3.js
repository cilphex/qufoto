/* update3.js */

var Login = {
	go: function() {
		$('do_sign_in').hide();
		$('signing_in').show();
		new Ajax.Request('/update3/login', {
			parameters: {
				ajax: 1,
				user: $F('user'),
				pass: $F('pass')
			},
			onSuccess: this.go_cb.bindAsEventListener(this),
			onFailure: this.go_failure.bindAsEventListener(this)
		});
	},
	go_cb: function(transport) {
		var response = transport.responseText.evalJSON();
		if (response.maintenance) {
			$('do_sign_in').show();
			$('signing_in', 'login_failure', 'login_error').invoke('hide');
			$('login_maintenance').showOrPulse();
		}
		else if (response.success) {
			$('login_failure', 'login_error', 'login_maintenance').invoke('hide');
			location.href = '/update3';
		}
		else {
			$('do_sign_in').show();
			$('signing_in', 'login_error', 'login_maintenance').invoke('hide');
			$('login_failure').showOrPulse();
		}
	},
	go_failure: function(transport) {
		$('do_sign_in').show();
		$('signing_in', 'login_failure', 'login_maintenance').invoke('hide');
		$('login_error').showOrPulse();
	},
	password: function() {
		var user_email = $F('user_email');
		$('recover').hide();
		$('recovering').show();
		new Ajax.Request('/update3/password', {
			parameters: {
				ajax: 1,
				user_email: user_email
			},
			onSuccess: this.password_cb.bindAsEventListener(this, user_email),
			onFailure: this.password_failure.bindAsEventListener(this)
		});
	},
	password_cb: function(transport, user_email) {
		var response = transport.responseText.evalJSON();
		$('lost').hide();
		if (response.success) {
			$('lost_success').show();
			$('recovery_email').update(response.email);
		}
		else {
			$('lost_failure').show();
			$('user_email_fail').update(user_email);
		}
	},
	password_failure: function(transport) {
		$('lost').hide();
		$('lost_error').show();
	}
};

var Portfolio = {
	initialize: function() {
		this.setupListeners();
		this.setupSortable();
	},
	setupListeners: function() {
		$$('input.new_portfolio').first()
			.observe('keyup', this.createInputKeyup.bindAsEventListener(this))
			.observe('keydown', this.createInputKeydown.bindAsEventListener(this))
	},
	setupSortable: function() {
		Sortable.create('portfolios', {
			constraint: 'vertical',
			handle: 'handle',
			onUpdate: this.orderUpdated.bind(this)
		});
	},
	showSaved: function(portfolio_id) {
		var saved_label = $('saved_' + portfolio_id);
		saved_label.writeAttribute('class', 'saved show');
		setTimeout(function() {
			saved_label.writeAttribute('class', 'saved hide');
		}, 2500);
	},
	orderUpdated: function() {
		new Ajax.Request('/update3/portfolio_order', {
			parameters: Sortable.serialize('portfolios')
		});
	},
	createInputKeyup: function(e) {
		var input = e.target;
		var title = input.value;
		var create_link = $('p_go');
		var error_div = $('p_error');
		var check = this.isValidPortfolioTitle(title);
		if (check.success) {
			input.addClassName('valid');
			create_link.removeClassName('disabled');
			error_div.hide();
		}
		else {
			input.removeClassName('valid');
			create_link.addClassName('disabled');
			if (!title.length) {
				error_div.hide();
			}
			else {
				error_div.update(check.reason).show();
			}
		}
	},
	createInputKeydown: function(e) {
		if (e.keyCode == 13)
			this.create();
	},
	isValidPortfolioTitle: function(title) {
		title = title.strip();
		var res = {success: 0};
		if (!title) {
			res.reason = 'The title cannot be empty';
		}
		else if (title.match(/&/)) {
			res.reason = 'The title cannot contain &ldquo;&amp;&rdquo;';
		}
		else {
			res.success = 1;
		}
		return res;
	},
	create: function() {
		var title = $F('new_portfolio_title');
		if (title.blank()) {
			alert('Please enter a portfolio title');
			return;
		}
		new Ajax.Request('/update3/portfolio_create', {
			parameters: {
				title: title
			},
			onSuccess: this.create_cb.bind(this, title),
			onFailure: this.create_failure.bind(this, title)
		});
	},
	create_cb: function(title, transport) {
		var response = transport.responseJSON;
		if (!response.success) {
			$('portfolios').insert({bottom: response.partial});
			this.setupSortable();
		}
	},
	create_failure: function(title, transport) {
		alert('Failed to created a new portfolio');
	},
	remove: function(portfolio_id) {
		if (!confirm('Are you sure you want to delete this portfolio?'))
			return;
		new Ajax.Request('/update3/portfolio_remove', {
			parameters: {
				id: portfolio_id
			},
			onSuccess: this.remove_cb.bind(this, portfolio_id),
			onFailure: this.remove_failure.bind(this, portfolio_id)
		});
	},
	remove_cb: function(portfolio_id, transport) {
		var response = transport.responseJSON;
		if (!response.success) {
			$('portfolio_li_' + portfolio_id).remove();
			this.setupSortable();
		}
	},
	remove_failure: function(portfolio_id, transport) {
		alert('The portfolio could not be deleted');
	},
	toggleVisibility: function(portfolio_id) {
		new Ajax.Request('/update3/portfolio_visibility', {
			parameters: {
				id: portfolio_id
			},
			onSuccess: this.toggleVisibility_cb.bind(this, portfolio_id),
			onFailure: this.toggleVisibility_failure.bind(this, portfolio_id)
		});
	},
	toggleVisibility_cb: function(portfolio_id, transport) {
		var response = transport.responseJSON;
		if (!response.success) {
			$('portfolio_li_' + portfolio_id)
				.writeAttribute('class', 'hidden_' + response.hidden)
				.select('a.visibility').first().update(response.hidden ? 'Hidden' : 'Visible');
			this.showSaved(portfolio_id);
		}
	},
	toggleVisibility_failure: function(portfolio_id, transport) {
		alert('The visibility could not be toggled');
	},
	rename: function(portfolio_id) {
		new Ajax.Request('/update3/portfolio_rename', {
			parameters: {
				id: portfolio_id,
				title: $F('rename_' + portfolio_id)
			},
			onSuccess: this.rename_cb.bind(this, portfolio_id)
		});
	},
	rename_cb: function(portfolio_id, transport) {
		var response = transport.responseJSON;
		if (!response.success) {
			$('title_' + portfolio_id).update(response.title);
			$('rename_' + portfolio_id).value = '';
			this.showSaved(portfolio_id);
		}
	},
	setPrivate: function(portfolio_id, privacy) {
		var form = $('options_' + portfolio_id).serialize(true);
		var privacy = form.privacy;
		var password = form.password;
		new Ajax.Request('/update3/portfolio_privacy', {
			parameters: {
				id: portfolio_id,
				privacy: privacy,
				password: password
			},
			onSuccess: this.setPrivate_cb.bind(this, portfolio_id)
		});
	},
	setPrivate_cb: function(portfolio_id, transport) {
		var response = transport.responseJSON;
		if (!response.success) {
			this.showSaved(portfolio_id);
		}
	},
	setMultimedia: function(portfolio_id) {
		new Ajax.Request('/update3/portfolio_multimedia', {
			parameters: {
				id: portfolio_id,
				multimedia: $('options_' + portfolio_id).serialize(true).multimedia
			},
			onSuccess: this.setPrivate_cb.bind(this, portfolio_id)
		});
	},
	setMultimedia_cb: function(portfolio_id, transport) {
		var response = transport.responseJSON;
		if (!response.success) {
			this.showSaved(portfolio_id);
		}
	},
	// Called from the iFrame
	audioSuccess: function(portfolio_id) {
		this.showSaved(portfolio_id);
		$('audio_upload_' + portfolio_id).hide();
		$('audiofile_' + portfolio_id).hide();
		$('audio_uploaded_' + portfolio_id).show();
	},
	audioError: function(portfolio_id) {
		alert('There was an error uploading the audio track');
	},
	playPauseAudio: function(portfolio_id, audio_file_url) {
		soundManager.destroySound('audio' + portfolio_id);
		if ($('audio_play_' + portfolio_id).innerHTML == 'Preview') {
			soundManager.play('audio' + portfolio_id, audio_file_url);
			$('audio_play_' + portfolio_id).update('Stop');
		}
		else {
			soundManager.stop('audio' + portfolio_id);
			$('audio_play_' + portfolio_id).update('Preview');
		}
	},
	deleteAudio: function(portfolio_id) {
		if (!confirm('Are you sure you want to delete this audio track?'))
			return;
		new Ajax.Request('/update3/portfolio_delete_audio', {
			parameters: {
				id: portfolio_id
			},
			onSuccess: this.deleteAudio_cb.bind(this, portfolio_id)
		});
	},
	deleteAudio_cb: function(portfolio_id, transport) {
		var response = transport.responseJSON;
		if (!response.success) {
			$('audio_uploaded_' + portfolio_id).hide();
			$('audio_upload_' + portfolio_id).show();
		}
	}
};

var Images = {
	current_image: null,
	type: null,
	initialize: function(type) {
		this.type = type;
		if (this.type == 'thumbs') {
			this.setupObservers();
			this.setupDroppables();
		}
		this.setupSortable();
	},
	setupObservers: function() {
		$('detail')
			.observe('click', function() {
				$('detail').hide();
			})
		.select('.inner').first().observe('click', function(e) {
			Event.stop(e);
		});
		Draggables.addObserver({
			onStart: function(eventName, draggable, event) {
				$(draggable.element).addClassName('dragging');
				$('portfolio_drop').addClassName('visible');
			},
			onEnd: function(eventName, draggable, event) {
				$(draggable.element).removeClassName('dragging');
				$('portfolio_drop').removeClassName('visible');
			}
		});
	},
	setupDroppables: function() {
		$('portfolio_drop').select('li.droppable').each(function(el) {
			Droppables.add(el, {
				hoverclass: 'drop_hover',
				onDrop: function(dragged, dropped, event) {
					console.log(this, 'dragged image', $(dragged).readAttribute('imageid'), 'into portfolio', $(dropped).readAttribute('portfolioid'));
					var portfolio_id = parseInt($(dropped).readAttribute('portfolioid'));
					var image_id = parseInt($(dragged).readAttribute('imageid'));
					Images.changePortfolio.bind(Images, image_id, portfolio_id).delay(0.5);
				}
			});
		});
	},
	setupSortable: function() {
		var constraint = this.type == 'list' ? 'vertical' : false;
		Sortable.create('images', {
			constraint: constraint,
			handle: 'handle',
			onUpdate: this.orderUpdated.bind(this)
		});
	},
	// Sometimes after an ajax request, or when performing some kind of drop-out
	// animation, the dom will not be updated before the sortable is re-done. so
	// delay it by a bit to prevent that
	setupSortableDelay: function(seconds) {
		this.setupSortable.bind(this).delay(seconds);
	},
	orderUpdated: function() {
		new Ajax.Request('/update3/image_order', {
			parameters: Sortable.serialize('images')
		});
	},
	remove: function(image_id) {
		new Ajax.Request('/update3/image_remove', {
			parameters: {
				id: image_id
			},
			onSuccess: this.remove_cb.bind(this, image_id),
			onFailure: this.remove_failure.bind(this, image_id)
		});
	},
	remove_cb: function(image_id, transport) {
		var response = transport.responseJSON;
		if (!response.success) {
			var image_el = $('image_' + image_id);
			image_el.setStyle({zIndex: 3})
			if (this.type == 'thumbs')
				image_el.dropOut();
			else
				image_el.fade();
			this.setupSortableDelay(1);
		}
	},
	remove_failure: function(image_id, transport) {
		alert('The image could not be removed');
	},
	showPortfolio: function(portfolio_id, type) {
		console.log('portfolio id', portfolio_id);
		new Ajax.Updater('images', '/update3/image_portfolio_partial', {
			parameters: {
				id: portfolio_id,
				type: this.type
			},
			onSuccess: this.showPortfolio_cb.bind(this)
		});
	},
	showPortfolio_cb: function(transport) {
		// The portfolio is already updated in the DOM because we used Ajax.Updater
		this.setupSortableDelay(0.25);
	},
	changePortfolio: function(image_id, portfolio_id) {
		console.log('moving image', image_id, 'to portfolio', portfolio_id);
		new Ajax.Request('/update3/image_portfolio', {
			parameters: {
				image_id: image_id,
				portfolio_id: portfolio_id
			},
			onSuccess: this.changePortfolio_cb.bind(this, image_id),
			onFailure: this.changePortfolio_failure.bind(this, image_id)
		});
	},
	changePortfolio_cb: function(image_id, transport) {
		var response = transport.responseJSON;
		if (!response.success) {
			$('image_' + image_id).shrink();
			this.setupSortableDelay(1);
		}
	},
	changePortfolio_failure: function(image_id, transport) {
		alert('The image could not be moved');
	},
	getDetail: function(image_id) {
		this.current_image = null;
		$('image_detail').hide();
		$('image_loading').show();
		$('detail').show();
		new Ajax.Updater('image_detail', '/update3/image_detail_partial', {
			parameters: {
				id: image_id
			},
			onSuccess: function(image_id) {
				this.current_image = image_id;
				$('image_loading').hide();
				$('image_detail').show();
			}.bind(this, image_id),
			onFailure: function() {
				alert('The image could not be loaded')
			}
		});
	},
	// List view save
	save: function(image_id) {
		new Ajax.Request('/update3/image_update', {
			parameters: {
				id: image_id,
				title: $F('image_title_' + image_id),
				description: $F('image_description_' + image_id)
			},
			onSuccess: this.save_cb.bind(this, image_id),
			onFailure: this.save_failure.bind(this, image_id)
		});
	},
	save_cb: function(image_id, transport) {
		$('image_' + image_id)
			.setStyle({background: '#dfffe2'})
			.morph({background: '#fff'});
	},
	save_failure: function(image_id, transport) {
		alert('The changes could not be saved');
	},
	// Thumbnail view save
	saveDetail: function() {
		if (typeof this.current_image != 'number')
			alert('No image loaded yet');
		new Ajax.Request('/update3/image_update', {
			parameters: {
				id: this.current_image,
				title: $F('image_title'),
				description: $F('image_description')
			},
			onSuccess: this.saveDetail_cb.bind(this),
			onFailure: this.saveDetail_failure.bind(this)
		});
	},
	saveDetail_cb: function(transport) {
		$('detail').hide();
	},
	saveDetail_failure: function(transport) {
		alert('The changes could not be saved')
	}
};

var Messages = {
	expandAll: function() {
		$('messages').select('div.message').invoke('show');
	},
	remove: function(message_id) {
		new Ajax.Request('/update3/message_remove', {
			parameters: {
				id: message_id
			},
			onSuccess: this.remove_cb.bind(this, message_id),
			onFailure: this.remove_failure.bind(this, message_id)
		})
	},
	remove_cb: function(message_id, transport) {
		var response = transport.responseJSON;
		if (!response.success) {
			$('message_' + message_id).fade();
		}
	},
	remove_failure: function(message_id, transport) {
		alert('The message could not be deleted')
	}
};

var Upload = {

	// Uploaded at least one image
	uploaded: false,
	
	submit: function() {
		$('upload').hide();
		$('uploading').show();
		$('upload_form').submit();
	},
	submit_cb: function(response) {
		$('uploading').hide();
		$('upload').show();
		if (!response.success) {
			var img = new Image;
			img.src = response.image.url;
			var imgdiv = new Element('div', {'class': 'image'})
				.update(img) // useless div req'd for slideDown
				.hide();
			Event.observe(img, 'load', function() {
				$('uploaded_images').insert({top: imgdiv});
				imgdiv.slideDown();
			});
			Event.observe(img, 'click', function() {
				Images.getDetail(response.image.id);
			});
			if (!this.uploaded) {
				$('uploaded_title').appear();
				this.uploaded = true;
			}
		}
		else {
			this.submit_failure(response);
		}
	},
	submit_failure: function(response) {
		switch(response.success) {
			case 1:
				alert('Please select a file');
				break;
			case 2:
				alert('The image must be a JPG');
				break;
			default:
				alert('An unknown error occurred');
				break;
		}
	}
};

var Layout = {
	saveBanner: function() {
		$('banner_saving').update('Uploading...').show();
		$('banner_form').submit()
	},
	saveBanner_cb: function(response) {
		$('banner_saving').hide();
		if (!response.status) {
			$('banner_image').src = response.url;
			$('banner_image').show();
			$('banner_text').hide();
			$('banner_delete').show();
			$('banner_saved').show();
			Element.fade.delay(2.5, 'banner_saved');
		}
		else {
			this.saveBanner_failure(response.status);
		}
	},
	saveBanner_failure: function(status) {
		switch(status) {
			case 1:
				alert('Not a .jpg image');
				break;
		}
	},
	toggleBannerVisibility: function() {
		new Ajax.Request('/update3/layout_banner_visibility', {
			onSuccess: this.toggleBannerVisibility_cb.bind(this),
			onFailure: this.toggleBannerVisibility_failure.bind(this)
		});
	},
	toggleBannerVisibility_cb: function(transport) {
		var response = transport.responseJSON;
		if (!response.status) {
			$('banner_visibility')
				.writeAttribute('class', 'visible_' + response.visible)
				.update(response.visible ? 'Visible' : 'Hidden');
		}
	},
	toggleBannerVisibility_failure: function(transport) {
		alert('The change could not be saved');
	},
	deleteBanner: function() {
		$('banner_saving').update('Deleting...').show();
		new Ajax.Request('/update3/layout_banner_delete', {
			onSuccess: this.deleteBanner_cb.bind(this),
			onFailure: this.deleteBanner_failure.bind(this)
		});
	},
	deleteBanner_cb: function(transport) {
		$('banner_saving').hide();
		var response = transport.responseJSON;
		if (!response.status) {
			$('banner_image').hide();
			$('banner_text').show();
			$('banner_delete').hide();
			$('banner_saved').show();
			Element.fade.delay(2.5, 'banner_saved');
		}
		else {
			alert('There was an error');
		}
	},
	deleteBanner_failure: function(transport) {
		$('banner_saving').hide();
		alert('The change could not be saved');
	},


	saveSplash: function() {
		$('splash_saving').update('Uploading...').show();
		$('splash_form').submit()
	},
	saveSplash_cb: function(response) {
		$('splash_saving').hide();
		if (!response.status) {
			$('splash_image').src = response.url;
			$('splash_image').show();
			$('splash_text').hide();
			$('splash_delete').show();
			$('splash_saved').show();
			Element.fade.delay(2.5, 'splash_saved');
		}
		else {
			this.saveSplash_failure(response.status);
		}
	},
	saveSplash_failure: function(status) {
		switch(status) {
			case 1:
				alert('Not a .jpg image');
				break;
		}
	},
	toggleSplashVisibility: function() {
		new Ajax.Request('/update3/layout_splash_visibility', {
			onSuccess: this.toggleSplashVisibility_cb.bind(this),
			onFailure: this.toggleSplashVisibility_failure.bind(this)
		});
	},
	toggleSplashVisibility_cb: function(transport) {
		var response = transport.responseJSON;
		if (!response.status) {
			$('splash_visibility')
				.writeAttribute('class', 'visible_' + response.visible)
				.update(response.visible ? 'Visible' : 'Hidden');
		}
	},
	toggleSplashVisibility_failure: function(transport) {
		alert('The change could not be saved');
	},
	deleteSplash: function() {
		$('splash_saving').update('Deleting...').show();
		new Ajax.Request('/update3/layout_splash_delete', {
			onSuccess: this.deleteSplash_cb.bind(this),
			onFailure: this.deleteSplash_failure.bind(this)
		});
	},
	deleteSplash_cb: function(transport) {
		$('splash_saving').hide();
		var response = transport.responseJSON;
		if (!response.status) {
			$('splash_image').hide();
			$('splash_text').show();
			$('splash_delete').hide();
			$('splash_saved').show();
			Element.fade.delay(2.5, 'splash_saved');
		}
		else {
			alert('There was an error');
		}
	},
	deleteSplash_failure: function(transport) {
		$('splash_saving').hide();
		alert('The change could not be saved');
	},


	saveLinks: function() {
		$('save_info').hide();
		$('saving').show();
		var params = $('link_form').serialize(true);
		new Ajax.Request('/update3/layout_links_save', {
			parameters: params,
			onSuccess: this.saveLinks_cb.bind(this),
			onFailure: this.saveLinks_failure.bind(this)
		});
	},
	saveLinks_cb: function(transport) {
		$('saving').hide();
		$('save_info').show();
		$('saved').show();
		Element.fade.delay(2.5, 'saved');
	},
	saveLinks_failure: function(transport) {
		$('saving').hide();
		$('save_info').show();
		alert('The changes could not be saved');
	},
	saveStatus: function(status) {
		$('status_save').hide();
		$('status_saving').show();
		new Ajax.Request('/update3/layout_status_save', {
			parameters: {
				status: status
			},
			onSuccess: this.saveStatus_cb.bind(this),
			onFailure: this.saveStatus_failure.bind(this)
		});
	},
	saveStatus_cb: function(transport) {
		$('status_saving').hide();
		$('status_save').show();
		var response = transport.responseJSON;
		if (!response.status) {
			$('status_saved').show();
			Element.fade.delay(2.5, 'status_saved');
			if (response.enabled) {
				$('enabled').show();
				$('disabled').hide();
			}
			else {
				$('enabled').hide();
				$('disabled').show();
			}
		}
		else {
			this.saveStatus_failure(transport);
		}
	},
	saveStatus_failure: function(transport) {
		$('status_saving').hide();
		$('status_save').show();
		alert('The change could not be saved');
	},
	saveJS: function() {
		$('js_save').hide();
		$('js_saving').show();
		new Ajax.Request('/update3/layout_javascript_save', {
			parameters: {
				javascript: $F('js_text')
			},
			onSuccess: this.saveJS_cb.bind(this),
			onFailure: this.saveJS_failure.bind(this)
		});
	},
	saveJS_cb: function(transport) {
		$('js_saving').hide();
		$('js_save').show();
		$('js_saved').show();
		Element.fade.delay(2.5, 'js_saved');
	},
	saveJS_failure: function(transport) {
		$('js_saving').hide();
		$('js_save').show();
		alert('The changes could not be saved');
	},
};

var Basic = {
	saveInfo: function() {
		$('save_info').hide();
		$('saving').show();
		var params = $('info_form').serialize(true);
		new Ajax.Request('/update3/basic_info_save', {
			parameters: params,
			onSuccess: this.saveInfo_cb.bind(this),
			onFailure: this.saveInfo_failure.bind(this)
		});
	},
	saveInfo_cb: function(transport) {
		$('saving').hide();
		$('save_info').show();
		$('saved').show();
		Element.fade.delay(2.5, 'saved');
	},
	saveInfo_failure: function(transport) {
		$('saving').hide();
		$('save_info').show();
		alert('The changes could not be saved');
	},
	saveBio: function() {
		$('bio_save').hide();
		$('bio_saving').show();
		new Ajax.Request('/update3/basic_bio_save', {
			parameters: {
				biography: $F('bio_text')
			},
			onSuccess: this.saveBio_cb.bind(this),
			onFailure: this.saveBio_failure.bind(this)
		});
	},
	saveBio_cb: function(transport) {
		$('bio_saving').hide();
		$('bio_save').show();
		$('bio_saved').show();
		Element.fade.delay(2.5, 'bio_saved');
	},
	saveBio_failure: function(transport) {
		$('bio_saving').hide();
		$('bio_save').show();
		alert('The changes could not be saved');
	},
	saveBioPic_cb: function(response) {
		if (!response.status) {
			$('biopic_bg').setStyle({backgroundImage: 'url(' + response.url + ')'})
		}
		else {
			this.saveBioPic_failure(response.status);
		}
	},
	saveBioPic_failure: function(status) {
		switch(status) {
			case 1:
				alert('Not a .jpg image');
				break;
		}
	},
	toggleBioVisibility: function() {
		new Ajax.Request('/update3/basic_bio_visibility', {
			onSuccess: this.toggleBioVisibility_cb.bind(this),
			onFailure: this.toggleBioVisibility_failure.bind(this)
		});
	},
	toggleBioVisibility_cb: function(transport) {
		var response = transport.responseJSON;
		if (!response.status) {
			$('bio_visibility')
				.writeAttribute('class', 'visible_' + response.visible)
				.update(response.visible ? 'Visible' : 'Hidden');
		}
	},
	toggleBioVisibility_failure: function(transport) {
		alert('The change could not be saved');
	},
	toggleBioPicVisibility: function() {
		new Ajax.Request('/update3/basic_biopic_visibility', {
			onSuccess: this.toggleBioPicVisibility_cb.bind(this),
			onFailure: this.toggleBioPicVisibility_failure.bind(this)
		});
	},
	toggleBioPicVisibility_cb: function(transport) {
		var response = transport.responseJSON;
		if (!response.status) {
			$('biopic_visibility')
				.writeAttribute('class', 'visible_' + response.visible)
				.update(response.visible ? 'Visible' : 'Hidden');
		}
	},
	toggleBioPicVisibility_failure: function(transport) {
		alert('The change could not be saved');
	},
	toggleResumeVisibility: function() {
		new Ajax.Request('/update3/basic_resume_visibility', {
			onSuccess: this.toggleResumeVisibility_cb.bind(this),
			onFailure: this.toggleResumeVisibility_failure.bind(this)
		});
	},
	toggleResumeVisibility_cb: function(transport) {
		var response = transport.responseJSON;
		if (!response.status) {
			$('resume_visibility')
				.writeAttribute('class', 'visible_' + response.visible)
				.update(response.visible ? 'Visible' : 'Hidden');
		}
	},
	toggleResumeVisibility_failure: function(transport) {
		alert('The change could not be saved');
	},
	saveResume_cb: function(response) {
		if (!response.status) {
			$('uploaded_false').hide();
			$('uploaded_true').show();
			$('uploaded')
				.setStyle({background: '#dfffe2'})
				.morph({background: '#f6f6f6'}, {duration: 3.0});
		}
		else {
			console.log('failure');
			this.saveResume_failure(response.status);
		}
	},
	saveResume_failure: function(status) {
		switch(status) {
			case 1:
				alert('Not a .pdf file');
				break;
		}
	},
	deleteResume: function() {
		new Ajax.Request('/update3/basic_resume_delete', {
			onSuccess: this.deleteResume_cb.bind(this),
			onFailure: this.deleteResume_failure.bind(this)
		});
	},
	deleteResume_cb: function(transport) {
		var response = transport.responseJSON;
		if (!response.status) {
			$('uploaded_true').hide();
			$('uploaded_false').show();
		}
	},
	deleteResume_failure: function(transport) {
		alert('The resume could not be deleted');
	}
};

var Settings = {
	savePassword: function() {
		$('save_info').hide();
		$('saving').show();
		var params = $('password_form').serialize(true);
		new Ajax.Request('/update3/settings_password_save', {
			parameters: params,
			onSuccess: this.savePassword_cb.bind(this),
			onFailure: this.savePassword_failure.bind(this)
		});
	},
	savePassword_cb: function(transport) {
		$('saving').hide();
		$('save_info').show();
		var response = transport.responseJSON;
		switch(response.status) {
			case 0:
				$('password_form', 'password_changed').invoke('toggle');
				break;
			case 1:
				alert('Your password was incorrect');
				break;
			case 2:
				alert('One of your passwords is empty');
				break;
			case 3:
				alert('Your passwords do not match');
				break;
		}
	},
	savePassword_failure: function(transport) {
		$('saving').hide();
		$('save_info').show();
		alert('The change could not be saved');
	}
};















