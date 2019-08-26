/*___________________________________________________________________________________________________________________________________________________
 _ jquery.mb.components                                                                                                                             _
 _                                                                                                                                                  _
 _ file: jquery.mb.vimeo_player.js                                                                                                                   _
 _ last modified: 26/12/16 15.39                                                                                                                    _
 _                                                                                                                                                  _
 _ Open Lab s.r.l., Florence - Italy                                                                                                                _
 _                                                                                                                                                  _
 _ email: matteo@open-lab.com                                                                                                                       _
 _ site: http://pupunzi.com                                                                                                                         _
 _       http://open-lab.com                                                                                                                        _
 _ blog: http://pupunzi.open-lab.com                                                                                                                _
 _ Q&A:  http://jquery.pupunzi.com                                                                                                                  _
 _                                                                                                                                                  _
 _ Licences: MIT, GPL                                                                                                                               _
 _    http://www.opensource.org/licenses/mit-license.php                                                                                            _
 _    http://www.gnu.org/licenses/gpl.html                                                                                                          _
 _                                                                                                                                                  _
 _ Copyright (c) 2001-2016. Matteo Bicocchi (Pupunzi);                                                                                              _
 ___________________________________________________________________________________________________________________________________________________*/

var get_vimeo_videoID = function( url ) {

	var videoID;
	if( url.indexOf( "vimeo.com" ) > 0 ) {
		videoID = url.substr( url.lastIndexOf( "/" ) + 1, url.length );
	} else {
		videoID = url.length > 15 ? null : url;
	}

	return videoID
};


( function( $ ) {
	jQuery.vimeo_player = {
		name: "jquery.mb.vimeo_player",
		author: "Matteo Bicocchi (pupunzi)",
		version: "1.0.6",
		build: "373",
		defaults: {
			containment: "body",
			ratio: "16/9", // "auto", "16/9", "4/3"
			videoURL: null,
			startAt: 0,
			stopAt: 0,
			autoPlay: true,
			vol: 50, // 1 to 100
			addRaster: false,
			opacity: 1,
			mute: false,
			loop: true,
			showControls: true,
			show_vimeo_logo: true,
			stopMovieOnBlur: true,
			realfullscreen: true,
			mobileFallbackImage: null,
			gaTrack: true,
			optimizeDisplay: true,
			mask: false,
			align: "center,center", // top,bottom,left,right
			onReady: function( player ) {}
		},
		/**
		 *  @fontface icons
		 *  */
		controls: {
			play: "P",
			pause: "p",
			mute: "M",
			unmute: "A",
			fullscreen: "O",
			showSite: "R",
			logo: "V"
		},
		buildPlayer: function( options ) {

			var isIframe = function() {
				var isIfr = false;
				try {
					if( self.location.href != top.location.href ) isIfr = true;
				} catch( e ) {
					isIfr = true;
				}
				return isIfr;
			};


			var script = document.createElement( 'script' );
			script.src = "https://player.vimeo.com/api/player.js";
			script.onload = function() {
				jQuery( document ).trigger( "vimeo_api_loaded" );
			};
			document.head.appendChild( script );

			return this.each( function() {

				var vimeo_player = this;
				var $vimeo_player = jQuery( vimeo_player );
				vimeo_player.loop = 0;
				vimeo_player.opt = {};
				vimeo_player.state = {};
				vimeo_player.id = vimeo_player.id || "YTP_" + new Date().getTime();
				$vimeo_player.addClass( "vimeo_player" );

				var property = $vimeo_player.data( "property" ) && typeof $vimeo_player.data( "property" ) == "string" ? eval( '(' + $vimeo_player.data( "property" ) + ')' ) : $vimeo_player.data( "property" );

				jQuery.extend( vimeo_player.opt, jQuery.vimeo_player.defaults, options, property );

				vimeo_player.opt.ratio = vimeo_player.opt.ratio == "auto" ? "16/9" : vimeo_player.opt.ratio;

				if( eval( vimeo_player.opt.loop ) )
					vimeo_player.opt.loop = 9999;

				vimeo_player.isRetina = ( window.retina || window.devicePixelRatio > 1 );


				vimeo_player.canGoFullScreen = !( jQuery.browser.msie || jQuery.browser.opera || isIframe() );
				if( !vimeo_player.canGoFullScreen ) vimeo_player.opt.realfullscreen = false;

				vimeo_player.isAlone = false;
				vimeo_player.hasFocus = true;

				vimeo_player.videoID = this.opt.videoURL ? get_vimeo_videoID( this.opt.videoURL ) : $vimeo_player.attr( "href" ) ? get_vimeo_videoID( $vimeo_player.attr( "href" ) ) : false;

				vimeo_player.isSelf = vimeo_player.opt.containment == "self";
				vimeo_player.opt.containment = vimeo_player.opt.containment == "self" ? jQuery( this ) : jQuery( vimeo_player.opt.containment );
				vimeo_player.isBackground = vimeo_player.opt.containment.is( "body" );

				if( vimeo_player.isBackground && vimeo_player.backgroundIsInited )
					return;

				vimeo_player.canPlayOnMobile = vimeo_player.isSelf && jQuery( this ).children().length === 0;

				if( !vimeo_player.isSelf ) {
					$vimeo_player.hide();
				}

				var overlay = jQuery( "<div/>" ).css( {
					position: "absolute",
					top: 0,
					left: 0,
					width: "100%",
					height: "100%"
				} ).addClass( "vimeo_player_overlay" );

				if( vimeo_player.isSelf ) {
					// overlay.on( "click", function() {
					// 	$vimeo_player.togglePlay();
					// } )
				}

				var playerID = "vimeo_player_" + vimeo_player.id;

				var wrapper = jQuery( "<div/>" ).addClass( "vimeo_player_wrapper" ).attr( "id", "vimeo_player_wrapper_" + playerID );
				wrapper.css( {
					position: "absolute",
					zIndex: 0,
					minWidth: "100%",
					minHeight: "100%",
					left: 0,
					top: 0,
					overflow: "hidden",
					opacity: 0
				} );

				vimeo_player.playerBox = jQuery( "<iframe/>" ).attr( "id", playerID ).addClass( "playerBox" );
				vimeo_player.playerBox.css( {
					position: "absolute",
					zIndex: 0,
					width: "100%",
					height: "100%",
					top: -10,
					frameBorder: 0,
					overflow: "hidden",
					left: 0
				} ).attr( {
					src: "https://player.vimeo.com/video/" + vimeo_player.videoID + "?background=1&autopause=0"
				} );

				if( !jQuery.browser.mobile || vimeo_player.canPlayOnMobile )
					wrapper.append( vimeo_player.playerBox );
				else {
					if( vimeo_player.opt.mobileFallbackImage ) {
						wrapper.css( {
							backgroundImage: "url(" + vimeo_player.opt.mobileFallbackImage + ")",
							backgroundPosition: "center center",
							backgroundSize: "cover",
							backgroundRepeat: "no-repeat",
							opacity: 1
						} )
					};

					$vimeo_player.remove();
					return;
				}

				vimeo_player.opt.containment.children().not( "script, style" ).each( function() {
					if( jQuery( this ).css( "position" ) == "static" ) jQuery( this ).css( "position", "relative" );
				} );

				if( vimeo_player.isBackground ) {
					jQuery( "body" ).css( {
						boxSizing: "border-box"
					} );

					wrapper.css( {
						position: "fixed",
						top: 0,
						left: 0,
						zIndex: 0
					} );

				} else if( vimeo_player.opt.containment.css( "position" ) == "static" )
					vimeo_player.opt.containment.css( {
						position: "relative"
					} );

				vimeo_player.opt.containment.prepend( wrapper );
				vimeo_player.wrapper = wrapper;

				vimeo_player.playerBox.css( {
					opacity: 1
				} );

				if( !jQuery.browser.mobile ) {
					vimeo_player.playerBox.after( overlay );
					vimeo_player.overlay = overlay;
				}

				if( !vimeo_player.isBackground ) {
					overlay.on( "mouseenter", function() {
						if( vimeo_player.controlBar && vimeo_player.controlBar.length )
							vimeo_player.controlBar.addClass( "visible" );
					} ).on( "mouseleave", function() {
						if( vimeo_player.controlBar && vimeo_player.controlBar.length )
							vimeo_player.controlBar.removeClass( "visible" );
					} );
				}

				jQuery( document ).on( "vimeo_api_loaded", function() {

					vimeo_player.player = new Vimeo.Player( playerID, options );
					vimeo_player.player.ready().then( function() {

						var VEvent;

						function start() {
							vimeo_player.isReady = true;

							if( vimeo_player.opt.mute )
								setTimeout( function() {
									$vimeo_player.v_mute();
								}, 1000 );

							if( vimeo_player.opt.showControls )
								jQuery.vimeo_player.buildControls( vimeo_player );

							if( vimeo_player.opt.autoPlay )
								setTimeout( function() {

									$vimeo_player.v_play();

									setTimeout( function() {
										VEvent = jQuery.Event( 'VPStart' );
										$vimeo_player.trigger( VEvent );
									}, 1500 )

								}, 100 );
							else
								$vimeo_player.v_pause();

							VEvent = jQuery.Event( 'VPReady' );
							$vimeo_player.trigger( VEvent );

						}

						if( vimeo_player.opt.startAt ) {

							vimeo_player.player.play().then( function() {
								vimeo_player.player.pause();
							} );

							$vimeo_player.v_seekTo( vimeo_player.opt.startAt, function() {
								start()
							} );

						} else
							start();

						$vimeo_player.v_optimize_display();
						jQuery( window ).off( "resize.vimeo_player_" + vimeo_player.id ).on( "resize.vimeo_player_" + vimeo_player.id, function() {
							$vimeo_player.v_optimize_display();
						} );

						//PROGRESS
						vimeo_player.player.on( "progress", function( data ) {
							console.debug( "progress:: ", data );
						} );

						//ERROR
						vimeo_player.player.on( "error", function( data ) {
							vimeo_player.state = -1;
							//console.debug( "error:: ", data );
							// Trigger state events
							VEvent = jQuery.Event( 'VPError' );
							VEvent.error = data;
							$vimeo_player.trigger( VEvent );
						} );

						//PLAY
						vimeo_player.player.on( "play", function( data ) {
							vimeo_player.state = 1;
							$vimeo_player.trigger( "change_state" );

							if( vimeo_player.controlBar && vimeo_player.controlBar.length )
								vimeo_player.controlBar.find( ".vimeo_player_pause" ).html( jQuery.vimeo_player.controls.pause );

							if( typeof _gaq != "undefined" && eval( vimeo_player.opt.gaTrack ) ) _gaq.push( [ '_trackEvent', 'vimeo_player', 'Play', vimeo_player.videoID ] );
							if( typeof ga != "undefined" && eval( vimeo_player.opt.gaTrack ) ) ga( 'send', 'event', 'vimeo_player', 'play', vimeo_player.videoID );

							// Trigger state events
							VEvent = jQuery.Event( 'VPPlay' );
							VEvent.error = data;
							$vimeo_player.trigger( VEvent );

						} );

						//PAUSE
						vimeo_player.player.on( "pause", function( data ) {
							vimeo_player.state = 2;
							$vimeo_player.trigger( "change_state" );

							if( vimeo_player.controlBar && vimeo_player.controlBar.length )
								vimeo_player.controlBar.find( ".vimeo_player_pause" ).html( jQuery.vimeo_player.controls.play );

							VEvent = jQuery.Event( 'VPPause' );
							VEvent.time = data;
							$vimeo_player.trigger( VEvent );

						} );

						//SEEKED
						vimeo_player.player.on( "seeked", function( data ) {
							vimeo_player.state = 3;
							$vimeo_player.trigger( "change_state" )
						} );

						//ENDED
						vimeo_player.player.on( "ended", function( data ) {
							vimeo_player.state = 0;
							$vimeo_player.trigger( "change_state" );

							VEvent = jQuery.Event( 'VPEnd' );
							VEvent.time = data;
							$vimeo_player.trigger( VEvent );

						} );

						//TIME UPDATE
						vimeo_player.player.on( "timeupdate", function( data ) {

							vimeo_player.duration = data.duration;
							vimeo_player.percent = data.percent;
							vimeo_player.seconds = data.seconds;

							vimeo_player.state = 1;
							vimeo_player.player.getPaused().then( function( paused ) {
								if( paused )
									vimeo_player.state = 2;
							} );

							if( vimeo_player.opt.stopMovieOnBlur ) {
								if( !document.hasFocus() ) {
									if( vimeo_player.state == 1 ) {
										vimeo_player.hasFocus = false;
										$vimeo_player.v_pause();
										vimeo_player.document_focus = setInterval( function() {
											if( document.hasFocus() && !vimeo_player.hasFocus ) {
												vimeo_player.hasFocus = true;
												$vimeo_player.v_play();
												clearInterval( vimeo_player.document_focus );
											}
										}, 300 );
									}
								}
							}

							if( vimeo_player.opt.showControls ) {
								var controls = jQuery( "#controlBar_" + vimeo_player.id );
								var progressBar = controls.find( ".vimeo_player_pogress" );
								var loadedBar = controls.find( ".vimeo_player_loaded" );
								var timeBar = controls.find( ".vimeo_player_seek_bar" );
								var totW = progressBar.outerWidth();
								var currentTime = Math.floor( data.seconds );
								var totalTime = Math.floor( data.duration );
								var timeW = ( currentTime * totW ) / totalTime;
								var startLeft = 0;
								var loadedW = data.percent * 100;
								loadedBar.css( {
									left: startLeft,
									width: loadedW + "%"
								} );
								timeBar.css( {
									left: 0,
									width: timeW
								} );

								if( data.duration ) {
									vimeo_player.controlBar.find( ".vimeo_player_time" ).html( jQuery.vimeo_player.formatTime( data.seconds ) + " / " + jQuery.vimeo_player.formatTime( data.duration ) );
								} else {
									vimeo_player.controlBar.find( ".vimeo_player_time" ).html( "-- : -- / -- : --" );
								}
							}

							if( vimeo_player.opt.addRaster ) {
								var classN = vimeo_player.opt.addRaster == "dot" ? "raster-dot" : "raster";
								vimeo_player.overlay.addClass( vimeo_player.isRetina ? classN + " retina" : classN );
							} else {
								vimeo_player.overlay.removeClass( function( index, classNames ) {
									// change the list into an array
									var current_classes = classNames.split( " " ),
										// array of classes which are to be removed
										classes_to_remove = [];
									jQuery.each( current_classes, function( index, class_name ) {
										// if the classname begins with bg add it to the classes_to_remove array
										if( /raster.*/.test( class_name ) ) {
											classes_to_remove.push( class_name );
										}
									} );
									classes_to_remove.push( "retina" );
									// turn the array back into a string
									return classes_to_remove.join( " " );
								} )
							}

							vimeo_player.opt.stopAt = vimeo_player.opt.stopAt > data.duration ? data.duration - 0.6 : vimeo_player.opt.stopAt;
							var end_time = vimeo_player.opt.stopAt || data.duration - 0.6;

							if( data.seconds >= end_time ) {

								vimeo_player.loop = vimeo_player.loop || 0;

								if( vimeo_player.opt.loop && vimeo_player.loop < vimeo_player.opt.loop ) {
									$vimeo_player.v_seekTo( vimeo_player.opt.startAt );
									vimeo_player.loop++;

								} else {
									$vimeo_player.v_pause();
									vimeo_player.state = 0;
									$vimeo_player.trigger( "change_state" );
								}
							}

							// Trigger state events
							VEvent = jQuery.Event( 'VPTime' );
							VEvent.time = data.seconds;
							$vimeo_player.trigger( VEvent );

						} );

					} );

					$vimeo_player.on( "change_state", function() {
						console.debug( "player state:: ", vimeo_player.state );

						if( vimeo_player.state == 0 )
							vimeo_player.wrapper.fadeOut( 500, function() {
								$vimeo_player.v_seekTo( 0 );
							} );

					} )
				} );
			} )
		},

		formatTime: function( s ) {
			var min = Math.floor( s / 60 );
			var sec = Math.floor( s - ( 60 * min ) );
			return( min <= 9 ? "0" + min : min ) + " : " + ( sec <= 9 ? "0" + sec : sec );
		},

		play: function() {
			var vimeo_player = this.get( 0 );
			if( !vimeo_player.isReady )
				return this;

			vimeo_player.player.play();
			setTimeout( function() {
				vimeo_player.wrapper.fadeTo( 1000, vimeo_player.opt.opacity );
			}, 1000 );

			var controls = jQuery( "#controlBar_" + vimeo_player.id );

			if( controls.length ) {
				var playBtn = controls.find( ".mb_YTPPvimeo_player_playpause" );
				playBtn.html( jQuery.vimeo_player.controls.pause );
			}
			vimeo_player.state = 1;

			jQuery( vimeo_player ).css( "background-image", "none" );
			return this;
		},

		togglePlay: function( callback ) {
			var vimeo_player = this.get( 0 );
			if( vimeo_player.state == 1 )
				this.v_pause();
			else
				this.v_play();

			if( typeof callback == "function" )
				callback( vimeo_player.state );

			return this;
		},

		pause: function() {
			var vimeo_player = this.get( 0 );
			vimeo_player.player.pause();
			vimeo_player.state = 2;
			return this;
		},

		seekTo: function( val, callback ) {
			var vimeo_player = this.get( 0 );

			var seekTo = vimeo_player.opt.stopAt && ( val >= vimeo_player.opt.stopAt ) ? vimeo_player.opt.stopAt - 0.5 : val;

			vimeo_player.player.setCurrentTime( seekTo ).then( function( data ) {
				if( typeof callback == "function" )
					callback( data );
			} );
			return this;
		},

		setVolume: function( val ) {

			var vimeo_player = this.get( 0 );

			console.debug( "setVolume:: ", val );
			console.debug( "volume:: ", vimeo_player.opt.vol );

			if( !val && !vimeo_player.opt.vol && vimeo_player.isMute )
				jQuery( vimeo_player ).v_unmute();
			else if( ( !val && !vimeo_player.isMute ) || ( val && vimeo_player.opt.vol == val ) ) {
				if( !vimeo_player.isMute )
					jQuery( vimeo_player ).v_unmute();
				else
					jQuery( vimeo_player ).v_mute();
			} else {

				vimeo_player.opt.vol = val;
				vimeo_player.player.setVolume( vimeo_player.opt.vol );
				if( vimeo_player.volumeBar && vimeo_player.volumeBar.length )
					vimeo_player.volumeBar.updateSliderVal( val * 100 )
			}
			return this;
		},

		toggleVolume: function() {
			var vimeo_player = this.get( 0 );
			if( !vimeo_player ) return;

			if( vimeo_player.isMute ) {
				jQuery( vimeo_player ).v_unmute();
				return true;
			} else {
				jQuery( vimeo_player ).v_mute();
				return false;
			}
		},

		mute: function() {
			var vimeo_player = this.get( 0 );
			if( vimeo_player.isMute )
				return;
			vimeo_player.isMute = true;
			vimeo_player.player.setVolume( 0 );
			if( vimeo_player.volumeBar && vimeo_player.volumeBar.length && vimeo_player.volumeBar.width() > 10 ) {
				vimeo_player.volumeBar.updateSliderVal( 0 );
			}
			var controls = jQuery( "#controlBar_" + vimeo_player.id );
			var muteBtn = controls.find( ".vimeo_player_muteUnmute" );
			muteBtn.html( jQuery.vimeo_player.controls.unmute );

			jQuery( vimeo_player ).addClass( "isMuted" );

			if( vimeo_player.volumeBar && vimeo_player.volumeBar.length )
				vimeo_player.volumeBar.addClass( "muted" );

			return this;
		},

		unmute: function() {
			var vimeo_player = this.get( 0 );

			if( !vimeo_player.isMute )
				return;
			vimeo_player.isMute = false;

			jQuery( vimeo_player ).v_set_volume( vimeo_player.opt.vol );

			if( vimeo_player.volumeBar && vimeo_player.volumeBar.length ) vimeo_player.volumeBar.updateSliderVal( vimeo_player.opt.vol > .1 ? vimeo_player.opt.vol : .1 );
			var controls = jQuery( "#controlBar_" + vimeo_player.id );
			var muteBtn = controls.find( ".vimeo_player_muteUnmute" );
			muteBtn.html( jQuery.vimeo_player.controls.mute );
			jQuery( vimeo_player ).removeClass( "isMuted" );
			if( vimeo_player.volumeBar && vimeo_player.volumeBar.length )
				vimeo_player.volumeBar.removeClass( "muted" );

			return this;
		},

		changeMovie: function( obj ) {

			var vimeo_player = this.get( 0 );
			vimeo_player.player.loadVideo( obj.url ).then( function( id ) {

				jQuery( vimeo_player ).v_setState();


			} )
		},


		buildControls: function( vimeo_player ) {
			var data = vimeo_player.opt;

			if( jQuery( "#controlBar_" + vimeo_player.id ).length )
				return;

			vimeo_player.controlBar = jQuery( "<span/>" ).attr( "id", "controlBar_" + vimeo_player.id ).addClass( "vimeo_player_bar" ).css( {
				whiteSpace: "noWrap",
				position: vimeo_player.isBackground ? "fixed" : "absolute",
				zIndex: vimeo_player.isBackground ? 10000 : 1000
			} );
			var buttonBar = jQuery( "<div/>" ).addClass( "buttonBar" );
			/* play/pause button*/
			var playpause = jQuery( "<span>" + jQuery.vimeo_player.controls.play + "</span>" ).addClass( "vimeo_player_pause vimeo_icon" ).click( function() {
				if( vimeo_player.state == 1 ) jQuery( vimeo_player ).v_pause();
				else jQuery( vimeo_player ).v_play();
			} );
			/* mute/unmute button*/
			var MuteUnmute = jQuery( "<span>" + jQuery.vimeo_player.controls.mute + "</span>" ).addClass( "vimeo_player_muteUnmute vimeo_icon" ).click( function() {

				if( vimeo_player.isMute ) {
					jQuery( vimeo_player ).v_unmute();
				} else {
					jQuery( vimeo_player ).v_mute();
				}
			} );
			/* volume bar*/
			var volumeBar = jQuery( "<div/>" ).addClass( "vimeo_player_volume_bar" ).css( {
				display: "inline-block"
			} );
			vimeo_player.volumeBar = volumeBar;
			/* time elapsed */
			var idx = jQuery( "<span/>" ).addClass( "vimeo_player_time" );
			var vURL = "https://vimeo.com/" + vimeo_player.videoID;

			var movieUrl = jQuery( "<span/>" ).html( jQuery.vimeo_player.controls.logo ).addClass( "vimeo_url vimeo_icon" ).attr( "title", "view on Vimeo" ).on( "click", function() {

				console.debug( vURL );

				window.open( vURL, "viewOnVimeo" )
			} );

			var fullscreen = jQuery( "<span/>" ).html( jQuery.vimeo_player.controls.fullscreen ).addClass( "vimeo_fullscreen vimeo_icon" ).on( "click", function() {
				jQuery( vimeo_player ).v_fullscreen( data.realfullscreen );
			} );
			var progressBar = jQuery( "<div/>" ).addClass( "vimeo_player_pogress" ).css( "position", "absolute" ).click( function( e ) {
				timeBar.css( {
					width: ( e.clientX - timeBar.offset().left )
				} );
				vimeo_player.timeW = e.clientX - timeBar.offset().left;
				vimeo_player.controlBar.find( ".vimeo_player_loaded" ).css( {
					width: 0
				} );
				var totalTime = Math.floor( vimeo_player.duration );
				vimeo_player.goto = ( timeBar.outerWidth() * totalTime ) / progressBar.outerWidth();

				console.debug( vimeo_player.goto );

				jQuery( vimeo_player ).v_seekTo( parseFloat( vimeo_player.goto ) );
				vimeo_player.controlBar.find( ".vimeo_player_loaded" ).css( {
					width: 0
				} );
			} );
			var loadedBar = jQuery( "<div/>" ).addClass( "vimeo_player_loaded" ).css( "position", "absolute" );
			var timeBar = jQuery( "<div/>" ).addClass( "vimeo_player_seek_bar" ).css( "position", "absolute" );
			progressBar.append( loadedBar ).append( timeBar );
			buttonBar.append( playpause ).append( MuteUnmute ).append( volumeBar ).append( idx );
			if( data.show_vimeo_logo ) {
				buttonBar.append( movieUrl );
			}
			if( vimeo_player.isBackground || ( eval( vimeo_player.opt.realfullscreen ) && !vimeo_player.isBackground ) ) buttonBar.append( fullscreen );
			vimeo_player.controlBar.append( buttonBar ).append( progressBar );
			if( !vimeo_player.isBackground ) {
				//vimeo_player.controlBar.addClass( "inline_vimeo_player" );
				vimeo_player.wrapper.before( vimeo_player.controlBar );
			} else {
				jQuery( "body" ).after( vimeo_player.controlBar );
			}

			volumeBar.simpleSlider( {
				initialval: vimeo_player.opt.vol,
				scale: 100,
				orientation: "h",
				callback: function( el ) {
					if( el.value == 0 ) {
						jQuery( vimeo_player ).v_mute();
					} else {
						jQuery( vimeo_player ).v_unmute();
					}
					vimeo_player.player.setVolume( el.value / 100 );

					if( !vimeo_player.isMute )
						vimeo_player.opt.vol = el.value;
				}
			} );
		},

		optimizeVimeoDisplay: function( align ) {

			var vimeo_player = this.get( 0 );
			var vid = {};

			vimeo_player.opt.align = align || vimeo_player.opt.align;

			vimeo_player.opt.align = typeof vimeo_player.opt.align != "undefined " ? vimeo_player.opt.align : "center,center";
			var YTPAlign = vimeo_player.opt.align.split( "," );

			if( vimeo_player.opt.optimizeDisplay ) {
				var abundance = vimeo_player.isPlayer ? 0 : 80;
				var win = {};
				var el = vimeo_player.wrapper;

				win.width = el.outerWidth();
				win.height = el.outerHeight() + abundance;

				vid.width = win.width;


				vid.height = vimeo_player.opt.ratio == "16/9" ? Math.ceil( vid.width * ( 9 / 16 ) ) : Math.ceil( vid.width * ( 3 / 4 ) );

				vid.marginTop = -( ( vid.height - win.height ) / 2 );
				vid.marginLeft = 0;

				var lowest = vid.height < win.height;

				if( lowest ) {

					vid.height = win.height + abundance;
					vid.width = vimeo_player.opt.ratio == "16/9" ? Math.floor( vid.height * ( 16 / 9 ) ) : Math.floor( vid.height * ( 4 / 3 ) );

					vid.marginTop = 0;
					vid.marginLeft = -( ( vid.width - win.width ) / 2 );

				}

				for( var a in YTPAlign ) {

					if( YTPAlign.hasOwnProperty( a ) ) {

						var al = YTPAlign[ a ].replace( / /g, "" );

						switch( al ) {

							case "top":
								vid.marginTop = lowest ? -( ( vid.height - win.height ) / 2 ) : 0;
								break;

							case "bottom":
								vid.marginTop = lowest ? 0 : -( vid.height - win.height );
								break;

							case "left":
								vid.marginLeft = 0;
								break;

							case "right":
								vid.marginLeft = lowest ? -( vid.width - win.width ) : 0;
								break;

							default:
								if( vid.width > win.width )
									vid.marginLeft = -( ( vid.width - win.width ) / 2 );
								break;

						}
					}
				}

			} else {

				vid.width = "100%";
				vid.height = "100%";
				vid.marginTop = 0;
				vid.marginLeft = 0;

			}

			vimeo_player.playerBox.css( {

				width: vid.width,
				height: vid.height,
				marginTop: vid.marginTop,
				marginLeft: vid.marginLeft,
				maxWidth: "initial"

			} );

		},

		/**
		 *
		 * @param align
		 */
		setAlign: function( align ) {
			var $vimeo_player = this;

			$vimeo_player.v_optimize_display( align );
		},
		/**
		 *
		 * @param align
		 */
		getAlign: function() {
			var vimeo_player = this.get( 0 );
			return vimeo_player.opt.align;
		},


		fullscreen: function( real ) {
			var vimeo_player = this.get( 0 );
			var $vimeo_player = jQuery( vimeo_player );
			var VEvent;

			if( typeof real == "undefined" ) real = vimeo_player.opt.realfullscreen;
			real = eval( real );
			var controls = jQuery( "#controlBar_" + vimeo_player.id );
			var fullScreenBtn = controls.find( ".vimeo_fullscreen" );
			var videoWrapper = vimeo_player.isSelf ? vimeo_player.opt.containment : vimeo_player.wrapper;

			if( real ) {
				var fullscreenchange = jQuery.browser.mozilla ? "mozfullscreenchange" : jQuery.browser.webkit ? "webkitfullscreenchange" : "fullscreenchange";
				jQuery( document ).off( fullscreenchange ).on( fullscreenchange, function() {
					var isFullScreen = RunPrefixMethod( document, "IsFullScreen" ) || RunPrefixMethod( document, "FullScreen" );
					if( !isFullScreen ) {
						vimeo_player.isAlone = false;
						fullScreenBtn.html( jQuery.vimeo_player.controls.fullscreen );
						videoWrapper.removeClass( "vimeo_player_Fullscreen" );

						videoWrapper.fadeTo( 500, vimeo_player.opt.opacity );

						videoWrapper.css( {
							zIndex: 0
						} );

						if( vimeo_player.isBackground ) {
							jQuery( "body" ).after( controls );
						} else {
							vimeo_player.wrapper.before( controls );
						}
						jQuery( window ).resize();
						// Trigger state events
						VEvent = jQuery.Event( 'VPFullScreenEnd' );
						$vimeo_player.trigger( VEvent );

					} else {
						// Trigger state events
						VEvent = jQuery.Event( 'VPFullScreenStart' );
						$vimeo_player.trigger( VEvent );
					}
				} );
			}
			if( !vimeo_player.isAlone ) {
				function hideMouse() {
					vimeo_player.overlay.css( {
						cursor: "none"
					} );
				}

				jQuery( document ).on( "mousemove.vimeo_player", function( e ) {
					vimeo_player.overlay.css( {
						cursor: "auto"
					} );
					clearTimeout( vimeo_player.hideCursor );
					if( !jQuery( e.target ).parents().is( ".vimeo_player_bar" ) )
						vimeo_player.hideCursor = setTimeout( hideMouse, 3000 );
				} );

				hideMouse();

				if( real ) {
					videoWrapper.css( {
						opacity: 0
					} );
					videoWrapper.addClass( "vimeo_player_Fullscreen" );
					launchFullscreen( videoWrapper.get( 0 ) );
					setTimeout( function() {
						videoWrapper.fadeTo( 1000, 1 );
						vimeo_player.wrapper.append( controls );
						jQuery( vimeo_player ).v_optimize_display();

					}, 500 )
				} else videoWrapper.css( {
					zIndex: 10000
				} ).fadeTo( 1000, 1 );
				fullScreenBtn.html( jQuery.vimeo_player.controls.showSite );
				vimeo_player.isAlone = true;
			} else {
				jQuery( document ).off( "mousemove.vimeo_player" );
				clearTimeout( vimeo_player.hideCursor );
				vimeo_player.overlay.css( {
					cursor: "auto"
				} );
				if( real ) {
					cancelFullscreen();
				} else {
					videoWrapper.fadeTo( 1000, vimeo_player.opt.opacity ).css( {
						zIndex: 0
					} );
				}
				fullScreenBtn.html( jQuery.vimeo_player.controls.fullscreen );
				vimeo_player.isAlone = false;
			}

			function RunPrefixMethod( obj, method ) {
				var pfx = [ "webkit", "moz", "ms", "o", "" ];
				var p = 0,
					m, t;
				while( p < pfx.length && !obj[ m ] ) {
					m = method;
					if( pfx[ p ] == "" ) {
						m = m.substr( 0, 1 ).toLowerCase() + m.substr( 1 );
					}
					m = pfx[ p ] + m;
					t = typeof obj[ m ];
					if( t != "undefined" ) {
						pfx = [ pfx[ p ] ];
						return( t == "function" ? obj[ m ]() : obj[ m ] );
					}
					p++;
				}
			}

			function launchFullscreen( element ) {
				RunPrefixMethod( element, "RequestFullScreen" );
			}

			function cancelFullscreen() {
				if( RunPrefixMethod( document, "FullScreen" ) || RunPrefixMethod( document, "IsFullScreen" ) ) {
					RunPrefixMethod( document, "CancelFullScreen" );
				}
			}

			return this;
		}

	};

	jQuery.fn.vimeo_player = jQuery.vimeo_player.buildPlayer;
	jQuery.fn.v_play = jQuery.vimeo_player.play;
	jQuery.fn.v_toggle_play = jQuery.vimeo_player.togglePlay;
	jQuery.fn.v_change_movie = jQuery.vimeo_player.changeMovie;
	jQuery.fn.v_pause = jQuery.vimeo_player.pause;
	jQuery.fn.v_seekTo = jQuery.vimeo_player.seekTo;
	jQuery.fn.v_optimize_display = jQuery.vimeo_player.optimizeVimeoDisplay;
	jQuery.fn.v_set_align = jQuery.vimeo_player.setAlign;
	jQuery.fn.v_get_align = jQuery.vimeo_player.getAlign;
	jQuery.fn.v_fullscreen = jQuery.vimeo_player.fullscreen;
	jQuery.fn.v_mute = jQuery.vimeo_player.mute;
	jQuery.fn.v_unmute = jQuery.vimeo_player.unmute;
	jQuery.fn.v_set_volume = jQuery.vimeo_player.setVolume;
	jQuery.fn.v_toggle_volume = jQuery.vimeo_player.toggleVolume;

} )( jQuery );
;/*___________________________________________________________________________________________________________________________________________________
 _ jquery.mb.components                                                                                                                             _
 _                                                                                                                                                  _
 _ file: jquery.mb.browser.min.js                                                                                                                   _
 _ last modified: 07/06/16 22.34                                                                                                                    _
 _                                                                                                                                                  _
 _ Open Lab s.r.l., Florence - Italy                                                                                                                _
 _                                                                                                                                                  _
 _ email: matteo@open-lab.com                                                                                                                       _
 _ site: http://pupunzi.com                                                                                                                         _
 _       http://open-lab.com                                                                                                                        _
 _ blog: http://pupunzi.open-lab.com                                                                                                                _
 _ Q&A:  http://jquery.pupunzi.com                                                                                                                  _
 _                                                                                                                                                  _
 _ Licences: MIT, GPL                                                                                                                               _
 _    http://www.opensource.org/licenses/mit-license.php                                                                                            _
 _    http://www.gnu.org/licenses/gpl.html                                                                                                          _
 _                                                                                                                                                  _
 _ Copyright (c) 2001-2016. Matteo Bicocchi (Pupunzi);                                                                                              _
 ___________________________________________________________________________________________________________________________________________________*/

var nAgt=navigator.userAgent;
if(!jQuery.browser){var isTouchSupported=function(){var a=nAgt.msMaxTouchPoints,b="ontouchstart"in document.createElement("div");return a||b?!0:!1};jQuery.browser={};jQuery.browser.mozilla=!1;jQuery.browser.webkit=!1;jQuery.browser.opera=!1;jQuery.browser.safari=!1;jQuery.browser.chrome=!1;jQuery.browser.androidStock=!1;jQuery.browser.msie=!1;jQuery.browser.edge=!1;jQuery.browser.hasTouch=isTouchSupported();jQuery.browser.ua=nAgt;jQuery.browser.name=navigator.appName;jQuery.browser.fullVersion=""+
		parseFloat(navigator.appVersion);jQuery.browser.majorVersion=parseInt(navigator.appVersion,10);var nameOffset,verOffset,ix;if(-1!=(verOffset=nAgt.indexOf("Opera")))jQuery.browser.opera=!0,jQuery.browser.name="Opera",jQuery.browser.fullVersion=nAgt.substring(verOffset+6),-1!=(verOffset=nAgt.indexOf("Version"))&&(jQuery.browser.fullVersion=nAgt.substring(verOffset+8));else if(-1!=(verOffset=nAgt.indexOf("OPR")))jQuery.browser.opera=!0,jQuery.browser.name="Opera",jQuery.browser.fullVersion=nAgt.substring(verOffset+
		4);else if(-1!=(verOffset=nAgt.indexOf("MSIE")))jQuery.browser.msie=!0,jQuery.browser.name="Microsoft Internet Explorer",jQuery.browser.fullVersion=nAgt.substring(verOffset+5);else if(-1!=nAgt.indexOf("Trident")){jQuery.browser.msie=!0;jQuery.browser.name="Microsoft Internet Explorer";var start=nAgt.indexOf("rv:")+3,end=start+4;jQuery.browser.fullVersion=nAgt.substring(start,end)}else-1!=(verOffset=nAgt.indexOf("Edge"))?(jQuery.browser.edge=!0,jQuery.browser.name="Microsoft Edge",jQuery.browser.fullVersion=
		nAgt.substring(verOffset+5)):-1!=(verOffset=nAgt.indexOf("Chrome"))?(jQuery.browser.webkit=!0,jQuery.browser.chrome=!0,jQuery.browser.name="Chrome",jQuery.browser.fullVersion=nAgt.substring(verOffset+7)):-1<nAgt.indexOf("mozilla/5.0")&&-1<nAgt.indexOf("android ")&&-1<nAgt.indexOf("applewebkit")&&!(-1<nAgt.indexOf("chrome"))?(verOffset=nAgt.indexOf("Chrome"),jQuery.browser.webkit=!0,jQuery.browser.androidStock=!0,jQuery.browser.name="androidStock",jQuery.browser.fullVersion=nAgt.substring(verOffset+
		7)):-1!=(verOffset=nAgt.indexOf("Safari"))?(jQuery.browser.webkit=!0,jQuery.browser.safari=!0,jQuery.browser.name="Safari",jQuery.browser.fullVersion=nAgt.substring(verOffset+7),-1!=(verOffset=nAgt.indexOf("Version"))&&(jQuery.browser.fullVersion=nAgt.substring(verOffset+8))):-1!=(verOffset=nAgt.indexOf("AppleWebkit"))?(jQuery.browser.webkit=!0,jQuery.browser.safari=!0,jQuery.browser.name="Safari",jQuery.browser.fullVersion=nAgt.substring(verOffset+7),-1!=(verOffset=nAgt.indexOf("Version"))&&(jQuery.browser.fullVersion=
		nAgt.substring(verOffset+8))):-1!=(verOffset=nAgt.indexOf("Firefox"))?(jQuery.browser.mozilla=!0,jQuery.browser.name="Firefox",jQuery.browser.fullVersion=nAgt.substring(verOffset+8)):(nameOffset=nAgt.lastIndexOf(" ")+1)<(verOffset=nAgt.lastIndexOf("/"))&&(jQuery.browser.name=nAgt.substring(nameOffset,verOffset),jQuery.browser.fullVersion=nAgt.substring(verOffset+1),jQuery.browser.name.toLowerCase()==jQuery.browser.name.toUpperCase()&&(jQuery.browser.name=navigator.appName));-1!=(ix=jQuery.browser.fullVersion.indexOf(";"))&&
(jQuery.browser.fullVersion=jQuery.browser.fullVersion.substring(0,ix));-1!=(ix=jQuery.browser.fullVersion.indexOf(" "))&&(jQuery.browser.fullVersion=jQuery.browser.fullVersion.substring(0,ix));jQuery.browser.majorVersion=parseInt(""+jQuery.browser.fullVersion,10);isNaN(jQuery.browser.majorVersion)&&(jQuery.browser.fullVersion=""+parseFloat(navigator.appVersion),jQuery.browser.majorVersion=parseInt(navigator.appVersion,10));jQuery.browser.version=jQuery.browser.majorVersion}
jQuery.browser.android=/Android/i.test(nAgt);jQuery.browser.blackberry=/BlackBerry|BB|PlayBook/i.test(nAgt);jQuery.browser.ios=/iPhone|iPad|iPod|webOS/i.test(nAgt);jQuery.browser.operaMobile=/Opera Mini/i.test(nAgt);jQuery.browser.windowsMobile=/IEMobile|Windows Phone/i.test(nAgt);jQuery.browser.kindle=/Kindle|Silk/i.test(nAgt);jQuery.browser.mobile=jQuery.browser.android||jQuery.browser.blackberry||jQuery.browser.ios||jQuery.browser.windowsMobile||jQuery.browser.operaMobile||jQuery.browser.kindle;
jQuery.isMobile=jQuery.browser.mobile;jQuery.isTablet=jQuery.browser.mobile&&765<jQuery(window).width();jQuery.isAndroidDefault=jQuery.browser.android&&!/chrome/i.test(nAgt);
;/*___________________________________________________________________________________________________________________________________________________
 _ jquery.mb.components                                                                                                                             _
 _                                                                                                                                                  _
 _ file: jquery.mb.simpleSlider.min.js                                                                                                              _
 _ last modified: 16/05/15 23.45                                                                                                                    _
 _                                                                                                                                                  _
 _ Open Lab s.r.l., Florence - Italy                                                                                                                _
 _                                                                                                                                                  _
 _ email: matteo@open-lab.com                                                                                                                       _
 _ site: http://pupunzi.com                                                                                                                         _
 _       http://open-lab.com                                                                                                                        _
 _ blog: http://pupunzi.open-lab.com                                                                                                                _
 _ Q&A:  http://jquery.pupunzi.com                                                                                                                  _
 _                                                                                                                                                  _
 _ Licences: MIT, GPL                                                                                                                               _
 _    http://www.opensource.org/licenses/mit-license.php                                                                                            _
 _    http://www.gnu.org/licenses/gpl.html                                                                                                          _
 _                                                                                                                                                  _
 _ Copyright (c) 2001-2015. Matteo Bicocchi (Pupunzi);                                                                                              _
 ___________________________________________________________________________________________________________________________________________________*/

var nAgt=navigator.userAgent;if(!jQuery.browser){jQuery.browser={},jQuery.browser.mozilla=!1,jQuery.browser.webkit=!1,jQuery.browser.opera=!1,jQuery.browser.safari=!1,jQuery.browser.chrome=!1,jQuery.browser.androidStock=!1,jQuery.browser.msie=!1,jQuery.browser.ua=nAgt,jQuery.browser.name=navigator.appName,jQuery.browser.fullVersion=""+parseFloat(navigator.appVersion),jQuery.browser.majorVersion=parseInt(navigator.appVersion,10);var nameOffset,verOffset,ix;if(-1!=(verOffset=nAgt.indexOf("Opera")))jQuery.browser.opera=!0,jQuery.browser.name="Opera",jQuery.browser.fullVersion=nAgt.substring(verOffset+6),-1!=(verOffset=nAgt.indexOf("Version"))&&(jQuery.browser.fullVersion=nAgt.substring(verOffset+8));else if(-1!=(verOffset=nAgt.indexOf("OPR")))jQuery.browser.opera=!0,jQuery.browser.name="Opera",jQuery.browser.fullVersion=nAgt.substring(verOffset+4);else if(-1!=(verOffset=nAgt.indexOf("MSIE")))jQuery.browser.msie=!0,jQuery.browser.name="Microsoft Internet Explorer",jQuery.browser.fullVersion=nAgt.substring(verOffset+5);else if(-1!=nAgt.indexOf("Trident")||-1!=nAgt.indexOf("Edge")){jQuery.browser.msie=!0,jQuery.browser.name="Microsoft Internet Explorer";var start=nAgt.indexOf("rv:")+3,end=start+4;jQuery.browser.fullVersion=nAgt.substring(start,end)}else-1!=(verOffset=nAgt.indexOf("Chrome"))?(jQuery.browser.webkit=!0,jQuery.browser.chrome=!0,jQuery.browser.name="Chrome",jQuery.browser.fullVersion=nAgt.substring(verOffset+7)):nAgt.indexOf("mozilla/5.0")>-1&&nAgt.indexOf("android ")>-1&&nAgt.indexOf("applewebkit")>-1&&!(nAgt.indexOf("chrome")>-1)?(verOffset=nAgt.indexOf("Chrome"),jQuery.browser.webkit=!0,jQuery.browser.androidStock=!0,jQuery.browser.name="androidStock",jQuery.browser.fullVersion=nAgt.substring(verOffset+7)):-1!=(verOffset=nAgt.indexOf("Safari"))?(jQuery.browser.webkit=!0,jQuery.browser.safari=!0,jQuery.browser.name="Safari",jQuery.browser.fullVersion=nAgt.substring(verOffset+7),-1!=(verOffset=nAgt.indexOf("Version"))&&(jQuery.browser.fullVersion=nAgt.substring(verOffset+8))):-1!=(verOffset=nAgt.indexOf("AppleWebkit"))?(jQuery.browser.webkit=!0,jQuery.browser.safari=!0,jQuery.browser.name="Safari",jQuery.browser.fullVersion=nAgt.substring(verOffset+7),-1!=(verOffset=nAgt.indexOf("Version"))&&(jQuery.browser.fullVersion=nAgt.substring(verOffset+8))):-1!=(verOffset=nAgt.indexOf("Firefox"))?(jQuery.browser.mozilla=!0,jQuery.browser.name="Firefox",jQuery.browser.fullVersion=nAgt.substring(verOffset+8)):(nameOffset=nAgt.lastIndexOf(" ")+1)<(verOffset=nAgt.lastIndexOf("/"))&&(jQuery.browser.name=nAgt.substring(nameOffset,verOffset),jQuery.browser.fullVersion=nAgt.substring(verOffset+1),jQuery.browser.name.toLowerCase()==jQuery.browser.name.toUpperCase()&&(jQuery.browser.name=navigator.appName));-1!=(ix=jQuery.browser.fullVersion.indexOf(";"))&&(jQuery.browser.fullVersion=jQuery.browser.fullVersion.substring(0,ix)),-1!=(ix=jQuery.browser.fullVersion.indexOf(" "))&&(jQuery.browser.fullVersion=jQuery.browser.fullVersion.substring(0,ix)),jQuery.browser.majorVersion=parseInt(""+jQuery.browser.fullVersion,10),isNaN(jQuery.browser.majorVersion)&&(jQuery.browser.fullVersion=""+parseFloat(navigator.appVersion),jQuery.browser.majorVersion=parseInt(navigator.appVersion,10)),jQuery.browser.version=jQuery.browser.majorVersion}jQuery.browser.android=/Android/i.test(nAgt),jQuery.browser.blackberry=/BlackBerry|BB|PlayBook/i.test(nAgt),jQuery.browser.ios=/iPhone|iPad|iPod|webOS/i.test(nAgt),jQuery.browser.operaMobile=/Opera Mini/i.test(nAgt),jQuery.browser.windowsMobile=/IEMobile|Windows Phone/i.test(nAgt),jQuery.browser.kindle=/Kindle|Silk/i.test(nAgt),jQuery.browser.mobile=jQuery.browser.android||jQuery.browser.blackberry||jQuery.browser.ios||jQuery.browser.windowsMobile||jQuery.browser.operaMobile||jQuery.browser.kindle,jQuery.isMobile=jQuery.browser.mobile,jQuery.isTablet=jQuery.browser.mobile&&jQuery(window).width()>765,jQuery.isAndroidDefault=jQuery.browser.android&&!/chrome/i.test(nAgt);

(function(b){b.simpleSlider={defaults:{initialval:0,scale:100,orientation:"h",readonly:!1,callback:!1},events:{start:b.browser.mobile?"touchstart":"mousedown",end:b.browser.mobile?"touchend":"mouseup",move:b.browser.mobile?"touchmove":"mousemove"},init:function(c){return this.each(function(){var a=this,d=b(a);d.addClass("simpleSlider");a.opt={};b.extend(a.opt,b.simpleSlider.defaults,c);b.extend(a.opt,d.data());var e="h"==a.opt.orientation?"horizontal":"vertical",e=b("<div/>").addClass("level").addClass(e);
	d.prepend(e);a.level=e;d.css({cursor:"default"});"auto"==a.opt.scale&&(a.opt.scale=b(a).outerWidth());d.updateSliderVal();a.opt.readonly||(d.on(b.simpleSlider.events.start,function(c){b.browser.mobile&&(c=c.changedTouches[0]);a.canSlide=!0;d.updateSliderVal(c);"h"==a.opt.orientation?d.css({cursor:"col-resize"}):d.css({cursor:"row-resize"});c.preventDefault();c.stopPropagation()}),b(document).on(b.simpleSlider.events.move,function(c){b.browser.mobile&&(c=c.changedTouches[0]);a.canSlide&&(b(document).css({cursor:"default"}),
			d.updateSliderVal(c),c.preventDefault(),c.stopPropagation())}).on(b.simpleSlider.events.end,function(){b(document).css({cursor:"auto"});a.canSlide=!1;d.css({cursor:"auto"})}))})},updateSliderVal:function(c){var a=this.get(0);if(a.opt){a.opt.initialval="number"==typeof a.opt.initialval?a.opt.initialval:a.opt.initialval(a);var d=b(a).outerWidth(),e=b(a).outerHeight();a.x="object"==typeof c?c.clientX+document.body.scrollLeft-this.offset().left:"number"==typeof c?c*d/a.opt.scale:a.opt.initialval*d/a.opt.scale;
	a.y="object"==typeof c?c.clientY+document.body.scrollTop-this.offset().top:"number"==typeof c?(a.opt.scale-a.opt.initialval-c)*e/a.opt.scale:a.opt.initialval*e/a.opt.scale;a.y=this.outerHeight()-a.y;a.scaleX=a.x*a.opt.scale/d;a.scaleY=a.y*a.opt.scale/e;a.outOfRangeX=a.scaleX>a.opt.scale?a.scaleX-a.opt.scale:0>a.scaleX?a.scaleX:0;a.outOfRangeY=a.scaleY>a.opt.scale?a.scaleY-a.opt.scale:0>a.scaleY?a.scaleY:0;a.outOfRange="h"==a.opt.orientation?a.outOfRangeX:a.outOfRangeY;a.value="undefined"!=typeof c?
					"h"==a.opt.orientation?a.x>=this.outerWidth()?a.opt.scale:0>=a.x?0:a.scaleX:a.y>=this.outerHeight()?a.opt.scale:0>=a.y?0:a.scaleY:"h"==a.opt.orientation?a.scaleX:a.scaleY;"h"==a.opt.orientation?a.level.width(Math.floor(100*a.x/d)+"%"):a.level.height(Math.floor(100*a.y/e));"function"==typeof a.opt.callback&&a.opt.callback(a)}}};b.fn.simpleSlider=b.simpleSlider.init;b.fn.updateSliderVal=b.simpleSlider.updateSliderVal})(jQuery);
