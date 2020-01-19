// For AddThis
var addthis_config = {
    data_track_clickback: true
}

Array.prototype.contains = function (val) {
	return this.indexOf(val) >= 0;
}

// Use Object.extend instead of Element.prototype= because IE6 doesn't support that.  Thanks Prototype!
Object.extend(Element.Methods, {
	// Finds inputs with the given class name and returns the values of the ones that are selected.
	getValues: function (element, class_name) {
		return element.select('input.' + class_name).collect(function(input) {return input.checked ? input.value : 0}).without(0).reduce() || null;
	},
	// Pulses an element if it's visible; otherwise, makes it visible. (Requires Scriptaculous)
	showOrPulse: function (element) {
		element.visible() ? element.pulsate({pulses: 2, duration: 0.6}) : element.show ();
	},
	// Remove the class names from elements in the array passed in.
	removeClassNames: function (element, class_names) {
		for (var i = 0; i < class_names.length; i++) {
			element.removeClassName(class_names[i]);
		}
		return element;
	}
});
// Add the methods to the element class
Element.addMethods ();

function observe_domain_search () {
	$('domain_search').focus ();
	new Form.Element.Observer ('domain_search', 0.25, function (element, value) {
		value.blank () ? $('own_it').hide () : $('own_it').show ();
		element.removeClassName ('error');
	});
}

function domain_search () {
	console.log ('one');
	if ($F('domain_search').match(/^[a-z0-9-]*\.[a-z\.]{2,6}$/i)) {
		console.log ('match');	
	}
	else {
		console.log ('three');
		$('domain_search').addClassName ('error');
		console.log ('four');
		$('format').pulsate ({pulses: 3, duration: 1.2});
		console.log ('five');
	}
	console.log ('six');
}

function send_message () {
    $('contact_form').addClassName ('sending');
    $('loader').show ();
    new Ajax.Request ('/send_comment', {
        method: 'post',
        parameters: $('contact_form').serialize (true),
        onComplete: function () {
            $('contact_form').removeClassName ('sending');
            $('loader').hide ();
        },
        onSuccess: function (transport) {
            var response = transport.responseText.evalJSON ();
            if (response.success) {
                $('contact_form').update ('<p>Thanks! We\'ll get back to you as soon as possible.</p>');
            }
            else {
                alert ('Send failed (1).  Please try again.');
            }
        },
        onFailure: function () {
            alert ('Send failed (2).  Please try again.');
        }
    });
}

function insert_address (prefix, suffix) {
	var address = prefix + '@' + suffix;
	document.write ('<a href="mailto:' + address + '">' + address + '</a>');
}

var util = {
	postToUrl: function (path, params) {
		var form = new Element('form', {method: 'post', action: path, style: 'display: none;'});
		for (var key in params) {
			form.insert({bottom: new Element('input', {type: 'hidden', name: key, value: params[key]})});
		}
		$(document.body).insert({bottom: form});
		form.submit();
	},
	insertAddress: function (prefix, suffix) {
		var address = prefix + '@' + suffix;
		document.write ('<a href="mailto:' + address + '">' + address + '</a>');
	}
}

var Landing = {
	current_pane: 0,
	scroller: null,
	pages: [],
	dots: true,
	rotate: false,
	step_time: 10,
	z_index: 100,
	initialize: function () {
		this.gatherPages();
		if (this.rotate) {
			if (this.dots) this.setupDots();
			this.setupScroller();
		}
	},
	gatherPages: function () {
		var pages = [];
		$('graphic_area').select('div.page').each(function(el) {
			if (!el.hasClassName('disabled'))
				pages.push(el);
		});
		this.pages = pages;
	},
	setupScroller: function () {
		this.scroller = new PeriodicalExecuter(this.scroll.bind(this), this.step_time);
	},
	stopScroller: function () {
		if (this.scroller)
			this.scroller.stop();
	},
	scroll: function (next_pane) { // param is optional
		if (typeof next_pane != 'number')
			next_pane = this.current_pane == this.pages.length-1 ? 0 : this.current_pane + 1;
		var current = this.pages[this.current_pane];
		var next = this.pages[next_pane];
		current.morph({left: '-900px'});
		next.setStyle({left: '900px', zIndex: this.z_index}).show().morph({left: '0px'});
		if (this.dots) {
			$('dot_' + this.current_pane).removeClassName('selected');
			$('dot_' + next_pane).addClassName('selected');
		}
		this.current_pane = next_pane;
		this.z_index += 1;
	},
	setupDots: function () {
		var dots = new Element('div', {id: 'dots'}).hide();
		for (var i = 0; i < this.pages.length; i++) {
			var dot = new Element('a', {
				id: 'dot_' + i,
				href: '#'
			}).writeAttribute('onclick', 'return false;')
			  .observe('click', function (e, i) {
				this.showPane(i);
			}.bindAsEventListener(this, i));
			if (i == 0)
				dot.addClassName('selected');
			dots.insert({bottom: dot});
		}
		$('graphic_area').insert({after: dots});
		$('dots').appear();
	},
	showPane: function (i) {
		this.stopScroller();
		if (this.current_pane == i)
			return;
		var image_div = this.pages[i];
		if (this.current_pane == null) {
			image_div.show();
			this.current_pane = i;
		}
		else {
			this.scroll(i);
		}
	}
}

var Dictionary = {
	user_guide: [
		{
			title: 'I forgot my username or password',
			text: 'You can retrieve your username and password at any time by going to your website\'s '
				+ 'update area and using the "Lost username or password" link. (Your update area can be accessed at any time '
				+ 'by visiting your-url/update.) The "Lost username or password" form will send your sign-in information to '
				+ 'the email address we have on file for you (typically the email address attached to the PayPal account you '
				+ 'signed up with.)  If you forgot what that email address is, <a href="/contact">contact us</a> and we can '
				+ 'help you manually.'
		},
		{
			title: 'How do I change my password?',
			text: 'Your password can be changed under Personal > Password in your update area.'
		},
		{
			title: 'How do I transfer or redirect a domain to or from Qufoto?',
			text: 'Please see our help document on <a href="/domains">redirecting and transferring domains</a>.'
		},
		{
			title: 'Can I change my domain / website url?',
			text: 'If you just signed up and the domain you selected is already taken, or if you\'ve been using a domain '
				+ 'that you already owned, then you still have a free domain available to you from Qufoto with your subscription. '
				+ 'Just let us know what domain you would like and, if it\'s available, we\'ll attach it to your account for you.<br/><br/>'
				+ 'If you have already taken advantage of the free domain offer that comes with your subscription, you can still '
				+ 'change your domain to something new, but you\'ll need to purchase your new domain separately from a domain '
				+ 'registrar like <a href="http://godaddy.com">GoDaddy</a>, and then <a href="/domains">redirect it</a> to your Qufoto '
				+ 'website.  <em>After the domain has been redirected</em>, let us know about it and we can make the necessary changes '
				+ 'to your account.  Then your new domain will begin to work, and your previous domain will be detached.'
		},
		{
			title: 'Do you support video uploads?',
			text: 'Video uploads are currently not supported.'
		},
		{
			title: 'How does Qufoto protect images from being copied?',
			text: 'Right-clicks are disabled on all sites so that visitors cannot copy or download your images. Photos also cannot be dragged into folders or onto the desktop from your site.'
		},
		{
			title: 'What size should I upload my images at?',
			text: 'Photos can be uploaded at any size, but we generally recommend resizing to about 1000 pixels on the longest side before upload.  This way your photos will be large enough to fit any template and will also upload fast. Only the absolute pixel dimensions of your photos will matter, so <a href="http://www.nicholsonprints.com/Articles/dpi.htm" target="_blank">DPI can be anything</a>.'
		},
		{
			title: 'My images lose color saturation after upload',
			text: 'If you\'re experiencing a loss of color saturation in your images '
				+ 'after upload, try saving your images with one of the following color profiles:<ul>'
				+ '<li>sRGB IEC61966-2.1</li>'
				+ '<li>Adobe RGB (1998)</li>'
				+ '</ul>You may also try using Photoshop\'s "Save for web" option at 100% quality.'
		},
		/*{
			title: 'How do I change my website background?',
			text: 'Please see our help document on <a href="/customize">customizing your website</a>.'
		},*/
		{
			title: 'Banner color doesn\'t match the background of my site',
			text: 'If your banner doesn\'t match the background color of your website, try saving your images with one of the following color profiles:'
				+ '<ul><li>sRGB IEC61966-2.1</li><li>Adobe RGB (1998)</li></ul>You may also try using Photoshop\'s "Save for web" option at 100% quality.'
		},
		{
			title: 'Can I use Qufoto for something other than photography?',
			text: 'Yes, you definitely can.  Art, design, styling, fashion, hair and makeup, jewelry, etc. If you\'ve got images, you can make a Qufoto site.'
		},
		{
			// Potentially change this later if it is the case that a user can change their plan by going through
			// the subscription process and doesn't need to cancel their last one
			title: 'How do I upgrade or downgrade?',
			text: 'To upgrade or downgrade your account simply visit our <a href="/signup">signup page</a> and sign up for the plan you want to be on. Then '
				+ 'let us know that you\'ve made the switch and we\'ll cancel your original subscription and send you a refund for any overlapping days. Then '
				+ 'the switch will be applied to your account.'
		},
		{
			title: 'How do I create email addresses?',
			text: 'Please see our help document on <a href="/email">email addresses</a>.'
		},
		{
			title: 'How do I put a logo on my website or left-align it?',
			text: 'Adding a logo to the top of your website is simple.  Just visit Layout > Banner in your update area and upload a .jpg image. '
				+ 'The maximum banner dimensions are 920x100 pixels, so any image larger than that will be scaled down.<br/><br/>'
				+ '<strong>How do I left-align my logo?</strong><br/>To simulate a left-aligned banner, simply create a blank banner image that has '
				+ 'the same background color as your site at the max dimensions (920x100 pixels).  Then place your logo on the left-hand side of it and save '
				+ 'it as a new image. Upload this new image as your banner, and your logo will appear to be left-aligned with your site.'
		},
		{
			title: 'How do I change the order that my portfolios are displayed?',
			text: 'To change the order of your portfolios or set which portfolio is displayed first, you can drag and drop your portfolio titles on the '
				+ 'portfolios page in your update area.  Look for the grippy-looking part on the left side of each portfolio row.'
		},
		{
			title: 'How do I start using Google Analytics for statistics?',
			text: 'Please see our help document on <a href="/analytics">Google Analytics</a>.'
		},
		{
			title: 'How do I optimize my website for search engines?',
			text: 'Please see our help document on <a href="/seo">search engine optimization</a>.'
		},
		{
			title: 'Are Qufoto site Flash or HTML based?',
			text: 'All Qufoto sites are Flash-based, but they\'re wrapped in HTML so that they\'re completely searchable and visible to search engines.'
		},
		{
			title: 'Do you support multi-image / batch uploading?',
			text: 'Currently batch uploads are not supported.'
		},
		{
			title: 'My banner, biography, splash, or favicon image won\'t update',
			text: 'If you uploaded a new banner, bio, splash, or favicon image and are finding that an older version of the image is being displayed on your site, '
				+ 'your web browser has cached a copy of the last image.  Try clearing your browser cache and refreshing the page.'
		},
		{
			title: 'My website won\'t load',
			text: 'If you can see your "Down for maintenance" page, your site <em>is</em> loading but it may not be set up properly. '
				+ 'Please re-read our <a href="/getting_started">getting started guide</a> to make sure you haven\'t missed anything. '
				+ 'If you\'re sure you\'ve got all that covered, try putting your site down for maintenance, and then back online again.<br/><br/>'
				+ 'If you get a browser error when visiting your site and if you\'re using a domain that you already own, please check '
				+ 'to make sure that the <a href="/domains">nameservers for your domain</a> are set properly.<br/><br/>'
				+ 'If neither of these is the case, please <a href="/contact">send us a message</a> describing the problem.'
		},
		{
			title: 'How do I resubscribe?',
			text: 'To renew your subscription, simply visit our <a href="/signup">signup page</a> and subscribe for the same domain as before. You can ignore any '
				+ 'status messages that say your domain is already taken. Once you resubscribe your website should be back online shortly. '
				+ 'You will not need to redo anything.'
		},
		{
			title: 'Why was my subscription cancelled?',
			text: 'Qufoto does not cancel subscriptions unless we\'re specifically asked to.  If your subscription was canceled and it was not by you, '
				+ 'PayPal could not process your payment.  Likely reasons are expired credit cards or updated bank information.<br/><br/>If you would like '
				+ 'to reactivate your website, you can simply <a href="/signup">resubscribe</a> at any time. Your website is fully intact and you will not have '
				+ 'to redo anything.<br/><br/><strong>Please note:</strong> If you send us a comment asking why your subscription was cancelled, you will '
				+ 'probably receive a response saying exactly what this help item says.'
		},
		{
			title: 'Can I sign up with a credit card?',
			text: 'Yes. All of our payments are processed through PayPal, and a credit card is one of the many payment methods you can enter with them.'
		},
		{
			title: 'Can I sign up for a year in advance?',
			text: 'Currently yearly plans are not available, only monthly subscriptions.'
		},
		{
			title: 'Where can I find information on your company?',
			text: '<a href="/about">Right here!</a>'
		},
		{
			title: 'How do I make a favicon?',
			text: 'You can use <a href="http://www.photoshopsupport.com/tutorials/jennifer/favicon.html">this tutorial</a> to help you out.'
		},
		{
			title: 'Will Qufoto interview me?',
			text: 'We\'re always willing to consider new interviewees for our <a href="/interviews">photographer interviews</a> section. The only '
				+ 'requirement is that you\'re already a Qufoto user.  There\'s no guarantee we\'ll set up an interview, but if you\'re interested '
				+ 'just <a href="/contact">send us a message</a> letting us know that you\'d like to be considered.'
		}
	]
};

var UserGuide = {
	seconds_per_refresh: 0.5,
	query_delay: null,
	compact: false,
	
	// words under 5 chars that should act as keywords
	searchables: ['html', 'flash', 'video', 'copy', 'art', 'logo', 'email', 'order', 'batch', 'load', 'size'],
	unsearchables: ['qufoto', 'website', 'please', 'thanks', 'upload', 'update', 'images'],
	
	initialize: function (field, compact) {
		this.compact = compact || false;
		$(field).observe('keyup', UserGuide.delayQuery.bindAsEventListener(this));
	},
	delayQuery: function (e) {
		window.clearTimeout(this.query_delay);
		this.query_delay = this.getTopics.delay(this.seconds_per_refresh, e.target.value);
	},
	getTopics: function (query) {
		if (query.blank()) {
			$('query_results_wrap').hide();
			return;
		}
		var results = [];
		var query_words = query.toLowerCase().split(/[^a-zA-Z]+/);
		Dictionary.user_guide.each(function(topic) {
			var matches = [];
			var title = topic.title.toLowerCase().split(/[^a-zA-Z]+/);
			var text = topic.text.toLowerCase().split(/[^a-zA-Z]+/);
			query_words.each(function(word) {
				if ((word.length <= 5 || UserGuide.unsearchables.contains(word)) && !UserGuide.searchables.contains(word))
					return;
				if (title.contains(word) || text.contains(word)) {
					matches.push(word);
					return;
				}
			});
			if (matches.length) {
				var res = {title: topic.title, text: topic.text};
				matches.each(function(word) {
					var word_regex = new RegExp('([$\\s])(' + word + ')', 'i');          // just a little complication to preserve links
					res.title = res.title.gsub(word_regex, '#{1}<span>#{2}</span>');
					res.text = res.text.gsub(word_regex, '#{1}<span>#{2}</span>');
				});
				results.push(res);
			}
		});
		if (results.length) {
			var results_ul = UserGuide.generateResultsUl(results);
			$('no_results', 'maybe_results').invoke('hide');
			$('matches').show();
			$('query_results').update(results_ul).show();
		}
		else if (!UserGuide.compact && query.length < 40) {
			$('matches', 'query_results', 'no_results').invoke('hide');
			$('maybe_results').show();
		}
		else if (!UserGuide.compact) {
			$('matches', 'query_results', 'maybe_results').invoke('hide');
			$('no_results').show();
		}
		if (UserGuide.compact && !results.length)
			$('query_results_wrap').hide();
		else
			$('query_results_wrap').show();
	},
	generateResultsUl: function (results) {
		var results_ul = new Element('ul');
		results.each(function(result, index) {
			var onclick = UserGuide.compact ? "$('result_text_" + index + "').toggle(); return false;" : '';
			var style = UserGuide.compact ? 'display: none;' : '';
			results_ul.insert({
				bottom: new Element('li')
					.insert({bottom: new Element('a', {'class': 'title', href: '#', 'onclick': onclick}).update(result.title)})
					.insert({bottom: new Element('p', {'id': 'result_text_' + index, 'class': 'text', 'style': style}).update(result.text)})
			});
		});
		return results_ul;
	},
	showAll: function () {
		var results_ul = this.generateResultsUl(Dictionary.user_guide);
		$('no_results', 'maybe_results').invoke('hide');
		$('matches').show();
		$('query_results').update(results_ul).show();
		$('query_results_wrap').show();
	}
}

var Examples = {
	example_rows: null,
	initialize: function() {
		this.setupImageLoader();
	},
	setupImageLoader: function() {
		this.example_rows = $('examples').select('li').collect(function(li) {
			return {
				loaded: false,
				element: li
			}
		});
		if (window.addEventListener)
			window.addEventListener('scroll', this.showImages.bindAsEventListener(this), false);
		else
			window.attachEvent('onscroll', this.showImages.bindAsEventListener(this));
		this.showImages();
	},
	showImages: function(event) {
		this.example_rows.each(function(row) {
			var row_visible = row.element.cumulativeOffset().top < document.viewport.getScrollOffsets().top + document.viewport.getHeight();
			if (!row.loaded && row_visible) {
				var image = row.element.select('a.image img').first();
				image.observe('load', function() {
					$(this).appear({duration: 0.25});
				});
				image.src = image.readAttribute('rel');
				row.loaded = true;
			}
		});
	},
	showCategory: function(category) {
		$('example_menu').select('li').each(function(el) {
			el.removeClassName('selected');
		});
		$('category_' + category).addClassName('selected');
		$('examples').select('li').each(function(el) {
			var input = el.select('input').first();
			var cat = input.value;
			if (cat == category || category == 0 || (category == 'featured' && input.id == 'featured'))
				el.show();
			else
				el.hide();
		});
		this.showImages();
	}
}

var Interview = {
	secret_shown: false,
	secret_pulse: null,
	initialize: function (tinyurl) {
		this.setupFollower();
		this.setupSecret();
	},
	setupFollower: function () {
		$(document).observe('scroll', this.updateFollower.bindAsEventListener(this));
	},
	setupSecret: function () {
		$('social').select('a.reward').each(function(a) {
			a.observe('click', function() {
				Interview.showSecret();
			});
		});
	},
	updateFollower: function (event) {
		var div = $('image_area');
		if (document.viewport.getScrollOffsets().top > div.cumulativeOffset().top + div.getHeight())
			$('back').addClassName('fixed');
		else
			$('back').removeClassName('fixed');
	},
	swapImage: function (id) {
		$('image').fade({duration: 0.5, afterFinish: function () {
			$('image').src = $('thumb_' + id).src.gsub('thumb', 'pro');
			$('image').observe('load', function () {
				$(this).appear({duration: 0.5}).setStyle({width: 'auto'});
			});
		}});
	},
	showComments: function () {
		$('disqus_thread').show();
	},
	showSecret: function () {
		if (this.secret_shown)
			return;
		$('secret').appear({duration: 0.5});
		this.secret_pulse = new PeriodicalExecuter(function(pe) {
			$('secret').pulsate({pulses: 1, duration: 0.5});
		}, 45);
		this.secret_shown = true;
	},
	showReward: function () {
		if (this.secret_pulse)
			this.secret_pulse.stop();
		$('thanks').show();
		$('secret').hide();
	},
	doSecret: function () {
		util.postToUrl('/signup', {free_month: 1});
	}
}

var Contact = {
	send: function () {
		var name  = $F('message_name');
		var email = $F('message_email');
		var body  = $F('message_text');
		if (name.blank())
			$('message_name').addClassName('error');
		if (email.blank())
			$('message_email').addClassName('error');
		if (body.blank())
			$('message_text').addClassName('error');
		if (name.blank() || email.blank() || body.blank()) {
			alert('Please fill out all fields');
			return;
		}
		$('contact_form').disable();
		$('send_text').update('Sending...');
		$('send_loader').show();
		new Ajax.Request('/send_comment', {
			parameters: {
				name:  name,
				email: email,
				body:  body
			},
			onSuccess: this.send_cb.bindAsEventListener(this),
			onFailure: this.send_failure.bindAsEventListener(this)
		});
	},
	send_cb: function (transport) {
		var response = transport.responseText.evalJSON();
		$('contact_form').enable();
		$('send_text').update('Send comment');
		$('send_loader').hide();
		if (response.success) {
			$('contact_form').hide();
			$('message_sent').show();
		}
		else {
			alert('There was an error processing your comment (Type 1).  Please try again later.');
		}
	},
	send_failure: function () {
		$('contact_form').enable();
		$('send_text').update('Send comment');
		$('send_loader').hide();
		alert('There was an error processing your comment (Type 2). Please try again later.');
	}
}

var Signup = {
	last_domain: '',
	initialize: function () {
		$('domain').focus();
	},
	setDomain: function (domain) {
		if (domain != this.last_domain) {
			$('available', 'taken', 'taken_warning', 'invalid', 'invalid_warning').invoke('hide');
			$('check').show();
		}
		this.last_domain = domain;
	},
	checkDomain: function () {
		new Ajax.Request('/check_domain', {
			parameters: {
				domain: $F('domain')
			},
			onSuccess: this.checkDomain_cb.bindAsEventListener(this)
		});
	},
	checkDomain_cb: function (transport) {
		var response = transport.responseText.evalJSON();
		if (response.available) {
			$('check', 'taken', 'invalid', 'taken_warning', 'invalid_warning').invoke('hide');
			$('available').show();
		}
		else if (response.invalid) {
			$('check', 'available', 'taken', 'taken_warning').invoke('hide');
			$('invalid', 'invalid_warning').invoke('show');
		}
		else {
			$('check', 'available', 'invalid', 'invalid_warning').invoke('hide');
			$('taken', 'taken_warning').invoke('show');
		}
	},
	planSelected: function () {
		$('plan_warning').hide();
	},
	doSignup: function () {
		var domain = $F('domain');
		var plan1 = $('plan1');
		var plan2 = $('plan2');
		if (domain.blank()) {
			alert('Please enter a domain name');
			return;
		}
		if (!plan1.checked && !plan2.checked) {
			$('plan_warning').show();
			return;
		}
		if (plan1.checked) {
			var title = 'Qufoto Standard Subscription';
			$('plan_title').value = title;
			$('plan_rate').value = '19.00';
		}
		else {
			var title = 'Qufoto Pro Subscription';
			$('plan_title').value = title;
			$('plan_rate').value = '29.00';
		}
		$('custom').value = domain;
		$('signup_form').submit();
	}
}

var Thankyou = {
	checkReferrer: function () {
		if ($F('referrer') == 4 || $F('referrer') == 5 || $F('referrer') == 6) {
	        $('specify_reference').show ();
	    } else {
	        $('specify_reference').hide ();
	    }
	},
	sendReferrer: function () {
		if ($F('referrer') == 0) {
	        alert('Please select a valid option');
	    } 
	    else if ($F('referrer') == 4 && $F('referrer_detail') == '') {
	        alert('Please enter the name or website of the user.');
	    }
	    else if ($F('referrer') == 6 && $F('referrer_detail') == '') {
	        alert('Please enter where you heard about us from.');
	    }
	    else {
	        var referrers = ['invalid option', 'Facebook Advertisement', 'Google (search result)', 'Google (advertisement)', 'a Qufoto user', 'a website', 'a specific source', 'Bing (advertisement)']
	        var detail = ($F('referrer') == 4 || $F('referrer') == 5 || $F('referrer') == 6) ? $F('referrer_detail') : 'none';
	        new Ajax.Request('/send_referrer', {
	            //method: 'post',
	            parameters: {
	                refer_user: $F('user'),
	                refer_email: $F('email'),
	                refer_type: referrers[$F('referrer')],
	                refer_detail: detail
	            },
	            onComplete: this.sendReferrer_cb.bindAsEventListener(this)
	        });
	    }
	},
	sendReferrer_cb: function (transport) {
		$('reference').update('Excellent!');
	}
}