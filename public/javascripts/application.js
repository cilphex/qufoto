// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

function boldTags(element) {
    $(element).value = '[b]' + $(element).value + '[/b]';
    $(element).focus();
}

function italicTags(element) {
    $(element).value = '[i]' + $(element).value + '[/i]';
    $(element).focus();
}

function show(element) {
    $(element).style.display = 'block';
}

function hide(element) {
    $(element).style.display = 'none';
}

// doesn't work?
function toggle(element) {
    $(element).style.display = ($(element).style.display == 'block' ? 'none' : 'block');
}

function navMouseover(element) {
    $(element).src = "/images/" + element + "_white.png";
}

function navMouseout(element) {
    $(element).src = "/images/" + element + ".png";
}

function refresh(element, location) {
    $(element).src = location;
}

function enableField(element) {
    $(element).disabled = false;
}

function enableFieldSetText(element, text) {
    $(element).disabled = false;
    $(element).value = text;
}

function disableField(element) {
    $(element).disabled = true;
}

function disableFieldSetText(element, text) {
    $(element).value = text;
    $(element).disabled = true;
}

function clearField(element) {
    $(element).value = "";
}

// taken from: http://www.dynamicdrive.com/dynamicindex16/maxlength.htm (maxlength for textareas)
function ismaxlength(obj){
    var mlength=obj.getAttribute? parseInt(obj.getAttribute("maxlength")) : ""
    if (obj.getAttribute && obj.value.length>mlength)
    obj.value=obj.value.substring(0,mlength)
}

/* Signup ------------------------------------------------------- */

var domain_text = "Enter domain name...";
function domainFocus () {
	if ($F('domain') == domain_text)
		$('domain').clear ();
}
function domainBlur () {
	if (!$('domain').present ())
		$('domain').value = domain_text;
}
// Yes, this is all very clear and easy to DOM hack.  But if you do,
// we'll notice and you won't get anything free anyway.
function checkReferralCode () {
	if ($F('referral_code') == '56F980') {
		var res = ''
			+ '<input type="hidden" name="a1" value="0"/>'
			+ '<input type="hidden" name="p1" value="1"/>'
			+ '<input type="hidden" name="t1" value="M"/>';
		$('lite_referral').update (res);
		$('pro_referral').update (res);
		$('referral_code').addClassName ('good_to_go');
	}
	else {
		$('lite_referral').update ();
		$('pro_referral').update ();
		$('referral_code').removeClassName ('good_to_go');
	}
}
function submitLite () {
	$('customLite').value = $F('domain') + '|' + $F('referral_code');
    if ($F('domain') == domain_text)
        alert ('Please enter a domain name.');
    else
        $('form_lite').submit ();
}
function submitPro () {
	$('customPro').value = $F('domain') + '|' + $F('referral_code');
    if ($F('domain') == domain_text)
        alert ('Please enter a domain name.');
    else
        $('form_pro').submit ();
}

/* Thankyou ------------------------------------------------------- */

// Thank you refferrer
function checkReferrer () {
    if ($F('referrer') == 4 || $F('referrer') == 5 || $F('referrer') == 6) {
        $('specify_reference').show ();
    } else {
        $('specify_reference').hide ();
    }
}
function sendReferrer () {
    if ($F('referrer') == 0) {
        alert ('Please select a valid option');
    } 
    else if ($F('referrer') == 4 && $F('referrer_detail') == '') {
        alert ('Please enter the name or website of the user.');
    }
    else if ($F('referrer') == 6 && $F('referrer_detail') == '') {
        alert ('Please enter where you heard about us from.');
    }
    else {
        var referrers = ['invalid option', 'Facebook Advertisement', 'Google (search result)', 'Google (advertisement)', 'a Qufoto user', 'a website', 'a specific source', 'Bing (advertisement)']
        var detail = ($F('referrer') == 4 || $F('referrer') == 5 || $F('referrer') == 6) ? $F('referrer_detail') : 'none';
        new Ajax.Request ('/send_referrer', {
            method: 'post',
            parameters: {
                refer_user: $F('user'),
                refer_email: $F('email'),
                refer_type: referrers[$F('referrer')],
                refer_detail: detail
            },
            onComplete: function () {
                $('reference').update ('Excellent!');
            }
        });
    }
}

// V2 functions

function updateContent () {
    setTimeout("$('inner_content').innerHTML=$('hiddendiv').innerHTML", 300); 
    setTimeout("new Effect.Appear('content',{duration:0.3})", 300);
}

function showmenu (menu) {     // 'about', or 'videos'
    if (menu == 'about') {
        new Effect.toggle('about', 'slide', {duration:0.3});
        aboutdown = aboutdown == true ? false : true;
        if (videosdown) {
            new Effect.toggle('videos', 'slide', {duration:0.3});
            videosdown = false;
        }
    } else if (menu == 'videos') {
        new Effect.toggle('videos', 'slide', {duration:0.3});
        videosdown = videosdown == true ? false : true;
        if (aboutdown) {
            new Effect.toggle('about', 'slide', {duration:0.3});
            aboutdown = false;    
        }
    }
}

// FEATURED functions

function swap (u, i, name) {
    new Effect.Fade ('u' + u, {duration:0.5, fps:60});
    setTimeout ('appear(' + u + ', ' + i + ', "' + name + '")', 600);
}
function appear (u, i, name) {
    if (i < 10) i = '0' + i;
    pic = new Image;
    pic.src = '/images/featured/' + name + '/' + i + '.jpg';
    Event.observe (pic, 'load', function () {
        $('u' + u).src = '/images/featured/' + name + '/' + i + '.jpg';
        new Effect.Appear ('u' + u, {fps:60})
    });
}
var size = 11, updown = 0;
function toggleFontSize () {
    if (size == 11) updown = 1;
    if (size == 13) updown = -1;
    size += updown;
    $$('div.article p').each (function (p) {
        p.setStyle ({ fontSize:(size)+'px' });
    });
    if (size == 11) $('fontsize').innerHTML = "+ Increase font size";
    if (size == 13) $('fontsize').innerHTML = "- Decrease font size";
}
/* http://www.dynamicdrive.com/dynamicindex9/noright.htm */
function clickIE4() {
    if (event.button == 2) {
        return false;
    }
}
function clickNS4(e) {
    if (document.layers || document.getElementById && !document.all) {
        if (e.which == 2 || e.which == 3) {
            return false;
        }
    }
}

// UPDATE functions

/* Portfolios page */

function setVisibility (portfolio_id, value) {
	new Ajax.Updater ('status', '/update/portfolio_visibility', {
		parameters: {
			portfolio_id: portfolio_id,
			hidden: value
		},
		onLoading: function (request) {$('loader').show();},
		onComplete: function (request) {$('loader').hide();}
	});
}
function setMultimedia (portfolio_id, value) {
	new Ajax.Updater ('status', '/update/portfolio_slideshow', {
		parameters: {
			portfolio_id: portfolio_id,
			slideshow: value
		},
		onLoading: function (request) {$('loader').show();},
		onComplete: function (request) {$('loader').hide();}
	});
}
function savePrivacy (portfolio_id) {
	var privacy = $('private_on_' + portfolio_id).checked;
	var password = $F('password_' + portfolio_id);
	new Ajax.Updater ('status', '/update/portfolio_privacy', {
		parameters: {
			portfolio_id: portfolio_id,
			privacy: privacy,
			password: password
		},
		onLoading: function (request) {$('loader').show();},
		onComplete: function (request) {$('loader').hide();}
	});
}
function playPauseAudio (portfolio_id, audio_file_url) {
	if ($('audio_play_' + portfolio_id).innerHTML == 'Preview') {
		soundManager.play ('audio' + portfolio_id, audio_file_url);
		$('audio_play_' + portfolio_id).update ('Stop');
	}
	else {
		soundManager.stop ('audio' + portfolio_id);
		$('audio_play_' + portfolio_id).update ('Preview');
	}
}
function submitAudio (portfolio_id) {
	$('audio_upload_form_' + portfolio_id).submit();
	$('loader').show();
}
function audioSuccess (portfolio_id) {
	$('loader').hide();
	$('audio_upload_' + portfolio_id).hide ();
	$('audio_uploaded_' + portfolio_id).show ();
}
function audioError (portfolio_id) {
	alert ('Error uploading audio for portfolio id: ' + portfolio_id);
	$('loader').hide();
}
function deleteAudio (portfolio_id) {
	if (confirm ('Are you sure you want to delete this audio track?')) {
		new Ajax.Request ('/update/delete_portfolio_audio', {
			parameters: {portfolio_id: portfolio_id},
			onLoading: function (request) {$('loader').show();},
			onComplete: function (request) {
				var response = request.responseText.evalJSON ();
				$('loader').hide();
				if (response.status) {
					$('audio_uploaded_' + portfolio_id).hide ();
					$('audio_upload_' + portfolio_id).show ();
					$('status').update ('<span class="success">Success</span>');
				}
				else {
					$('tmp_file_' + portfolio_id).clear ();
					$('status').update ('<span class="error">Failure</span>');
				}
			}
		});
	}
}
function renamePortfolio (portfolio_id) {
	var new_title = $F('rename_' + portfolio_id);
	if (!new_title.blank()) {
		new Ajax.Request ('/update/rename_portfolio', {
			parameters: {
				portfolio_id: portfolio_id,
				new_title: new_title
			},
			onLoading: function (request) {$('loader').show();},
			onComplete: function (request) {
				var response = request.responseText.evalJSON ();
				$('loader').hide();
				if (response.status) {
					$('title_' + portfolio_id).update (new_title);
					$('rename_' + portfolio_id).clear ();
					$('status').update ('<span class="success">Success</span>');
				}
				else {
					$('status').update ('<span class="error">Failure</span>');
				}
			}
		});
	}
}
function deletePortfolio (portfolio_id, title) {
	if (confirm ('Are you sure you want to delete ' + title + '?')) {
		new Ajax.Updater ('portfolios', '/update/delete_portfolio', {
			parameters: {id: portfolio_id},
			onLoading: function (request) {$('loader').show();},
			onComplete: function (request) {$('loader').hide();}
		});
	}
}
function addPortfolio () {
	var title = $F('new_portfolio_title');
	if (title.blank ()) {
		alert ('Please enter a title for the new portfolio.');
	}
	else {
		new Ajax.Updater ('portfolios', '/update/add_portfolio', {
			parameters: {title: title},
			onLoading: function (request) {$('loader').show();},
			onComplete: function (request) {$('loader').hide();}
		});
	}
}
function saveJavascript () {
	var js = $F('js_text');
	new Ajax.Request('/update/update_javascript', {
		parameters: {javascript: js},
		onLoading: function (transport) {
			$('loader').show();
		},
		onComplete: function (transport) {
			$('loader').hide();
			$('status').update(transport.responseText);
		}
	});
}

/* Other... */

function editedImage (image_id, portfolio_id) {
    myLightWindow.deactivate ();
    if (portfolio_id != currentPortfolio) {
        new Effect.Fade ('item_' + image_id);
    }
}

var currentPortfolio = 0;
var newPortfolio = 0;
var outmouse = '';

function calculateTime () {
    times = document.getElementsByClassName('time');
    totaltime = 0;
    for (var x = 0; x < times.length; x++) {
        totaltime += parseInt (times[x].value);
    }
    seconds = totaltime % 60;
    if (seconds < 10)
        seconds = "0" + seconds;
    $('totaltime').innerHTML = Math.floor(totaltime/60) + ":" + seconds;
}

var addPortfolioDown = false;
var renamePortfolioDown = false;
var audioPortfolioDown = false;

function showPortfolioOption (option) {     // 'about', or 'videos'
    if (option == 'addportfolio') {
        new Effect.toggle('addportfolio', 'slide', {duration:0.3});
        addPortfolioDown = addPortfolioDown == true ? false : true;
        if (renamePortfolioDown) {
            new Effect.toggle('renameportfolio', 'slide', {duration:0.3});
            renamePortfolioDown = false;
        }
        if (audioPortfolioDown) {
            new Effect.toggle('audioportfolio', 'slide', {duration:0.3});
            audioPortfolioDown = false;
        }
    } else if (option == 'renameportfolio') {
        new Effect.toggle('renameportfolio', 'slide', {duration:0.3});
        renamePortfolioDown = renamePortfolioDown == true ? false : true;
        if (addPortfolioDown) {
            new Effect.toggle('addportfolio', 'slide', {duration:0.3});
            addPortfolioDown = false;
        }
        if (audioPortfolioDown) {
            new Effect.toggle('audioportfolio', 'slide', {duration:0.3});
            audioPortfolioDown = false;
        }
    } else if (option == 'audioportfolio') {
        new Effect.toggle('audioportfolio', 'slide', {duration:0.3});
        audioPortfolioDown = audioPortfolioDown == true ? false : true;
        if (renamePortfolioDown) {
            new Effect.toggle('renameportfolio', 'slide', {duration:0.3});
            renamePortfolioDown = false;
        }
        if (addPortfolioDown) {
            new Effect.toggle('addportfolio', 'slide', {duration:0.3});
            addPortfolioDown = false;
        }
    }
}

function showTemplate (template) {
    for (i = 0; i < 5; i++) {
        $('template'+i).style.display = 'none';
    }
    $('template'+template).style.display = 'block';
}

function selectTemplate (template) {
    for (i = 0; i < 5; i++) {
        $('templateSelect'+i).style.background = '#FFFFFF';
    }
    $('template').value = template;
    $('templateSelect'+template).style.background = '#D5EBFF';
    
    if (template == 2) {
        $$('div.prolayout').each (function (value, index) {
            value.style.display = 'block';
        }); 
    } else {
        $$('div.prolayout').each (function (value, index) {
            value.style.display = 'none';
        });
    }
}

function editImage (image) {
    myLightWindow.activateWindow({
    	href: '/update/edit_image?image_id=' + image,
    	title: 'Edit',
    	width: 481,
    	height: 476
    });
}

function previewImage (image_url) {
    myLightWindow.activateWindow({
    	href: image_url,
    	title: 'Preview'
    });
}

function do_alert (text) {
    alert (text);
}

function preset_color (color) {
    var bgcolor = '000000',
        innerbgcolor = '000000',
        textcolor = 'AAAAAA',
        thumbbgcolor = '222222',
        highlightcolor = '666666',
        descbgcolor = '222222';
    switch (color) {
        case 'black':
            break;
        case 'brown':
            bgcolor         = '381A04';
            innerbgcolor    = '381A04';
            textcolor       = 'CCCCCC'; 
            thumbbgcolor    = '99877A'; 
            highlightcolor  = '381A04';
            descbgcolor     = '432108';
            break;
        case 'white':
            bgcolor         = 'FFFFFF'; 
            innerbgcolor    = 'FFFFFF';
            textcolor       = '505050'; 
            thumbbgcolor    = 'EEEEEE'; 
            highlightcolor  = 'CCCCCC';
            descbgcolor     = 'E8E8E8';
            break;
        case 'bluegrey':
            bgcolor         = '222222'; 
            innerbgcolor    = '222222';
            textcolor       = '7A9CBB'; 
            thumbbgcolor    = '333333'; 
            highlightcolor  = '666666';
            descbgcolor     = '444444';
            break;
        case 'tan':
            bgcolor         = 'D8D8C0'; 
            innerbgcolor    = 'D8D8C0';
            textcolor       = '301800'; 
            thumbbgcolor    = '789090'; 
            highlightcolor  = '484830';
            descbgcolor     = 'c8c8b0';
            break;
    }
    $('bgcolor').value                          = bgcolor; 
    $('bgcolor_div').style.background           = '#' + bgcolor;
    $('innerbgcolor').value                     = innerbgcolor; 
    $('innerbgcolor_div').style.background      = '#' + innerbgcolor; 
    $('textcolor').value                        = textcolor; 
    $('textcolor_div').style.background         = '#' + textcolor; 
    $('thumbbgcolor').value                     = thumbbgcolor; 
    $('thumbbgcolor_div').style.background      = '#' + thumbbgcolor; 
    $('highlightcolor').value                   = highlightcolor; 
    $('highlightcolor_div').style.background    = '#' + highlightcolor;
    $('color5').value                           = descbgcolor; 
    $('color5_div').style.background            = '#' + descbgcolor; 
    $('status').update ();
}
function bg_type (type) {
    switch (parseInt(type)) {
        case 0:
            $('bgtype_1').hide ();
            $('bgtype_2').hide ();
            $('bgtype_2_details').hide ();
            break;
        case 1:
            $('bgtype_2').hide ();
            $('bgtype_2_details').hide ();
            $('bgtype_1').show ();
            break;
        case 2:
            $('bgtype_1').hide ();
            $('bgtype_2').show ();
            $('bgtype_2_details').show ();
            break;
    }
}
function bg_pos (type) {
    var bgpos = 'center center'
    switch (parseInt (type)) {
        case 1: bgpos = 'top left';         break;
        case 2: bgpos = 'top center';       break;
        case 3: bgpos = 'top right';        break;
        case 4: bgpos = 'center left';      break;
        case 5: bgpos = 'center right';     break;
        case 6: bgpos = 'bottom left';      break;
        case 7: bgpos = 'bottom center';    break;
        case 8: bgpos = 'bottom right';     break;
    }
    $('blue_dot').setStyle ({backgroundPosition: bgpos});
}
function bg_repeat (type) {
    switch (parseInt (type)) {
        case 0: $('blue_dot').setStyle ({backgroundRepeat: 'no-repeat'});   break;
        case 1: $('blue_dot').setStyle ({backgroundRepeat: 'repeat'});      break;
        case 2: $('blue_dot').setStyle ({backgroundRepeat: 'repeat-x'});   break;
        case 3: $('blue_dot').setStyle ({backgroundRepeat: 'repeat-y'});      break;
    }
}
function bg_gradient (i) {
    $$('#bgtype_1 a.gradient').each (function (el) {
        el.removeClassName ('selected');
    });
    $('gradient_' + i).addClassName ('selected');
    $('bggradient').value = i;
}
function deleteMessage (message_id) {
    new Ajax.Request ('/update/delete_message', {
        method: 'post',
        parameters: {
            message_id: message_id
        },
        onComplete: function (transport) {
            var response = transport.responseText.evalJSON ();
            if (response.deleted) {
                $('message_' + message_id).hide();
            }
        }
    });
}

/* Uploader ---------------------------------------------------------------- */

var UploadController = Class.create ({
	
	initialize: function () {
		
	},
	
	// This function is called via the iframe, when the server
	// sends a response to it after the upload is started
	begin: function (upload_id, uploading) {
		if (uploading) {
			$('more_stuff').update ('upload id ' + upload_id + ' is uploading');
			this.track (upload_id);
		}
		else {
			$('more_stuff').update ('upload id ' + upload_id + ' failed');
		}
	},
	track: function (upload_id) {
		console.log ('tracking upload id ' + upload_id);
	}
});

/* ------------------------------------------------------------------------- */


// ADMIN functions

function swapHidden () {
    showing = document.getElementsByClassName('show');
    for (i = 0; i < showing.length; i++) {
        showing[i].style.display = showing[i].style.display == 'none' ? 'block' : 'none';
    }
    hidden = document.getElementsByClassName('hide');
    for (i = 0; i < hidden.length; i++) {
        hidden[i].style.display = hidden[i].style.display == 'block' ? 'none' : 'block';
    }    
}
function toggleUpdateStatus () {
    new Ajax.Request ('/admin/toggle_update_status', {
        method: 'post',
        onComplete: function (transport) {
            var response = transport.responseText.evalJSON ();
            $('update_status').update (response.status);
        }
    });
}

function observeUsername () {
    new Form.Element.Observer ('username', 1.0, usernameCheck);
}
function usernameCheck () {
    new Ajax.Request ('/admin/check_user', {
        method: 'post',
        parameters: {
            username: $F('username')
        },
        onComplete: function (transport) {
            var response = transport.responseText.evalJSON ();
            if (response.available)
                $('username_availability').update('Available');
            else
                $('username_availability').update('Taken');
        }
    });
}

var Example = {
	initialize: function () {
		this.setupReorder();
	},
	setupReorder: function () {
		Sortable.create('examples', {
			handle: 'div.handle',
			onUpdate: this.reorder.bindAsEventListener(this)
		});
	},
	reorder: function (container) {
		new Ajax.Request('/admin/example_reorder', {
			parameters: Sortable.serialize('examples'),
			onSuccess: this.reorder_cb.bindAsEventListener(this)
		});
	},
	reorder_cb: function () {
		console.log('done');
	},
	addNew: function () {
		Sortable.destroy('examples');
		new Ajax.Request('/admin/example_create', {
			parameters: $('example_form').serialize(true),
			onSuccess: this.addNew_cb.bindAsEventListener(this)
		});
	},
	addNew_cb: function (transport) {
		$('examples').insert({bottom: transport.responseText}).show();
		$('no_examples').hide();
		$('example_form').reset();
		this.setupReorder();
	},
	remove: function (example_id) {
		Sortable.destroy('examples');
		new Ajax.Request('/admin/example_remove', {
			parameters: {example_id: example_id},
			onSuccess: this.remove_cb.bindAsEventListener(this, example_id)
		});
	},
	remove_cb: function (transport, example_id) {
		var response = transport.responseText.evalJSON();
		if (response.success) {
			$('example_' + example_id).remove();
		}
		this.setupReorder();
	},
	save: function (example_id) {
		new Ajax.Request('/admin/example_update', {
			parameters: $('example_form_' + example_id).serialize(true),
			onSuccess: this.save_cb.bindAsEventListener(this, example_id)
		});
	},
	save_cb: function (transport, example_id) {
		var response = transport.responseText.evalJSON();
		if (response.success) {
			$('saved_' + example_id).show();
			(function () {
				$('saved_' + example_id).fade();
			}).delay(5);
		}
		else {
			alert('Could not save');
		}
	},
	addImage: function (example_id) {
		$('image_upload_' + example_id).submit();
	},
	addImage_cb: function (success, example_id, image_url) {
		if (success) {
			$('image_area_' + example_id).update(new Element('img', {src: image_url})).insert({bottom: '&nbsp;'});
			$('image_upload_' + example_id).reset();
		}
		else {
			alert('Upload failed. Try JPG only.');
		}
	}
};

var Interviews = {
	initialize: function () {
		this.setupReorder();
	},
	setupReorder: function () {
		Sortable.create('interviews', {
			handle: 'div.handle',
			onUpdate: this.reorder.bindAsEventListener(this)
		});
	},
	reorder: function (container) {
		new Ajax.Request('/admin/interview_reorder', {
			parameters: Sortable.serialize('interviews'),
			onSuccess: this.reorder_cb.bindAsEventListener(this)
		});
	},
	reorder_cb: function () {
		console.log('done');
	}
};

var Interview = {
	id: null,
	initialize: function (id) {
		this.id = id;
		this.setupReorder();
	},
	setupReorder: function () {
		Sortable.create('images', {
			tag: 'div',
			handle: 'div.handle',
			constraint: null,
			onUpdate: this.reorder.bindAsEventListener(this)
		});
	},
	reorder: function (container) {
		new Ajax.Request('/admin/interview_image_reorder', {
			parameters: Sortable.serialize('images'),
			onSuccess: this.reorder_cb.bindAsEventListener(this)
		});
	},
	reorder_cb: function () {
		console.log('done');
	},
	save: function () {
		new Ajax.Request('/admin/update_interview', {
			parameters: {
				id:           this.id,
				interviewer:  $F('interviewer'),
				interviewee:  $F('interviewee'),
				url:          $F('url'),
				link:         $F('link'),
				caption:      $F('caption'),
				body:         $F('body'),
				bio:          $F('bio'),
				enabled:      $('enabled').checked ? true : false
			},
			onSuccess: this.save_cb.bindAsEventListener(this)
		});
	},
	save_cb: function (transport) {
		var response = transport.responseText.evalJSON();
		if (response.success) {
			if (!this.id) {
				this.id = response.interview_id;
				$('upload_form').show();
			}
			$('status').update('saved').removeClassName('error').addClassName('success');
		}
		else {
			$('status').update('ERROR').removeClassName('success').addClassName('error');
		}
	},
	destroy: function () {
		if (!confirm('Are you sure you want to delete this interview?'))
			return;
		new Ajax.Request('/admin/destroy_interview', {
			parameters: {id: this.id},
			onSuccess: this.destroy_cb.bindAsEventListener(this)
		});
	},
	destroy_cb: function (transport) {
		var response = transport.responseText.evalJSON();
		if (response.success) {
			location.href = '/admin/interviews';
		}
		else {
			alert('This interview could not be deleted');
		}
	},
	addImage: function () {
		if (!this.id) {
			alert('This interview must be created first.  That means save it.');
			return;
		}
		else {
			Sortable.destroy('images');
			$('interview_id').value = this.id;
			$('upload_form').submit();
		}
	},
	addImage_cb: function (success, image_id, image_url) {
		if (success) {
			var div = new Element('div', {id: 'image_' + image_id, 'class': 'image'});
			div.insert({bottom:
				new Element('img', {src: image_url})
			}).insert({bottom:
				new Element('a', {href: '#', onclick: 'Interview.removeImage(' + image_id + '); return false;'}).update('Remove')
			}).insert({bottom:
				new Element('div', {'class': 'handle'})
			});
			$('images').insert({bottom: div});
		}
		else {
			alert('Upload failed. Try JPG only.');
		}
		this.setupReorder();
	},
	removeImage: function (image_id) {
		new Ajax.Request('/admin/interview_remove_image', {
			parameters: {
				id: this.id,
				image_id: image_id
			},
			onSuccess: this.removeImage_cb.bindAsEventListener(this, image_id)
		});
	},
	removeImage_cb: function (transport, image_id) {
		var response = transport.responseText.evalJSON();
		if (response.success) {
			$('image_' + image_id).remove();
		}
		else {
			alert('Delete failed.');
		}
	},
	setPhotographer: function (image_id) {
		new Ajax.Request('/admin/interview_set_photographer', {
			parameters: {
				id: this.id,
				image_id: image_id
			},
			onSuccess: this.setPhotographer_cb.bindAsEventListener(this, image_id)
		});
	},
	setPhotographer_cb: function (transport, image_id) {
		var response = transport.responseText.evalJSON();
		if (response.success) {
			if (response.old_photographer_picid) {
				$('images').insert({bottom: $('image_' + response.old_photographer_picid).remove()});
			}
			if (image_id != 0 && image_id != response.old_photographer_picid)
				$('photographer_image').update($('image_' + image_id).remove());
		}
	}
};



