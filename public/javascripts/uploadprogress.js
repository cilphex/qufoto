var UploadProgress = {
    uploading: null,
    monitor: function(upid) {
        if(!this.periodicExecuter) {
            this.periodicExecuter = new PeriodicalExecuter(function() {
                if(!UploadProgress.uploading) return;
                //new Ajax.Request('/update/progress?upload_id=' + upid);
            	new Ajax.Request('/update/progress', {
					parameters: {
						upload_id: upid
					}
				});
			}, 1);
        }
        
        this.uploading = true;
        $('results').innerHTML = '.0%';
        $('uploadButton').disabled = true;
        this.StatusBar.reset();
          
        new Effect.Appear ('results');
        new Effect.Appear ('progress-bar');
    },
    
    update: function(total, current) {
        if(!this.uploading) return;
        var status     = current / total;
        var statusHTML = status.toPercentage();
        $('results').innerHTML   = statusHTML; // + " <small>(" + current.toHumanSize() + ' of ' + total.toHumanSize() + ")</small>";
        this.StatusBar.update(status, statusHTML);
    },
      
    finish: function() {
        this.uploading = false;
        this.StatusBar.finish();
        $('results').innerHTML = 'Finished!';
        $('uploadButton').disabled = false;
        $('uploadForm').reset();
        new Effect.Fade ('results', {delay:1.0});
    },
      
    cancel: function(msg) {
        if(!this.uploading) return;
        this.uploading = false;
        $('results').innerHTML = msg || 'canceled';
    },
      
    StatusBar: {
        statusBar: null,
        statusBarWidth: 300,
        
        reset: function() {
            $('progress-bar').setStyle ({width:'0px'});
        },
        
        update: function(status, statusHTML) {
            $('progress-bar').morph ({width:(this.statusBarWidth * status) + 'px'},{duration:0.4});
        },
        
        finish: function() {
            $('results').innerHTML  = '100%';
            $('progress-bar').morph ({width:this.statusBarWidth + 'px'}, {duration:0.4});
            new Effect.Fade ('progress-bar', {delay:1.0});
        }                      
    },
      
    FileField: {
        add: function() {
            new Insertion.Bottom('file-fields', '<p style="display:none"><input id="data" name="data" type="file" /> <a href="#" onclick="UploadProgress.FileField.remove(this);return false;">x</a></p>');
            $$('#file-fields p').last().visualEffect('blind_down', {duration:0.3});
        },
        
        remove: function(anchor) {
            anchor.parentNode.visualEffect('drop_out', {duration:0.25});
        }
    }
};

Number.prototype.bytes     = function() { return this; };
Number.prototype.kilobytes = function() { return this *  1024; };
Number.prototype.megabytes = function() { return this * (1024).kilobytes(); };
Number.prototype.gigabytes = function() { return this * (1024).megabytes(); };
Number.prototype.terabytes = function() { return this * (1024).gigabytes(); };
Number.prototype.petabytes = function() { return this * (1024).terabytes(); };
Number.prototype.exabytes =  function() { return this * (1024).petabytes(); };
['byte', 'kilobyte', 'megabyte', 'gigabyte', 'terabyte', 'petabyte', 'exabyte'].each(function(meth) {
    Number.prototype[meth] = Number.prototype[meth+'s'];
});

Number.prototype.toPrecision = function() {
    var precision = arguments[0] || 2;
    var s         = Math.round(this * Math.pow(10, precision)).toString();
    var pos       = s.length - precision;
    var last      = s.substr(pos, precision);
    return s.substr(0, pos) + (last.match("^0{" + precision + "}$") ? '' : '.' + last);
}

// (1/10).toPercentage()
// # => '10%'
Number.prototype.toPercentage = function() {
    return (this * 100).toPrecision() + '%';
}

Number.prototype.toHumanSize = function() {
    if(this < (1).kilobyte())  return this + " Bytes";
    if(this < (1).megabyte())  return (this / (1).kilobyte()).toPrecision()  + ' KB';
    if(this < (1).gigabytes()) return (this / (1).megabyte()).toPrecision()  + ' MB';
    if(this < (1).terabytes()) return (this / (1).gigabytes()).toPrecision() + ' GB';
    if(this < (1).petabytes()) return (this / (1).terabytes()).toPrecision() + ' TB';
    if(this < (1).exabytes())  return (this / (1).petabytes()).toPrecision() + ' PB';
    return (this / (1).exabytes()).toPrecision()  + ' EB';
}