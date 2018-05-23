# frozen_string_literal: true

require "browser/device/base"
require "browser/device/unknown"
require "browser/device/ipad"
require "browser/device/ipod_touch"
require "browser/device/iphone"
require "browser/device/playstation3"
require "browser/device/playstation4"
require "browser/device/psp"
require "browser/device/psvita"
require "browser/device/kindle"
require "browser/device/kindle_fire"
require "browser/device/wii"
require "browser/device/wiiu"
require "browser/device/blackberry_playbook"
require "browser/device/surface"
require "browser/device/tv"
require "browser/device/xbox_one"
require "browser/device/xbox_360"

module Browser
  class Device
    attr_reader :ua

    # Hold the list of device matchers.
    # Order is important.
    def self.matchers
      @matchers ||= [
        XboxOne,
        Xbox360,
        Surface,
        TV,
        BlackBerryPlaybook,
        WiiU,
        Wii,
        KindleFire,
        Kindle,
        PlayStation4,
        PlayStation3,
        PSVita,
        PSP,
        Ipad,
        Iphone,
        IpodTouch,
        Unknown
      ]
    end

    def initialize(ua)
      @ua = ua
    end

    def subject
      @subject ||= self.class.matchers
                       .map {|matcher| matcher.new(ua) }
                       .find(&:match?)
    end

    def id
      subject.id
    end

    def name
      subject.name
    end

    # Detect if browser is tablet (currently iPad, Android, Surface or
    # Playbook).
    def tablet?
      ipad? ||
        (platform.android? && !detect_mobile?) ||
        surface? ||
        playbook?
    end

    # Detect if browser is mobile.
    def mobile?
      detect_mobile? && !tablet?
    end

    def ipad?
      id == :ipad
    end

    def unknown?
      id == :unknown
    end

    def ipod_touch?
      id == :ipod_touch
    end
    alias_method :ipod?, :ipod_touch?

    def iphone?
      id == :iphone
    end

    def ps3?
      id == :ps3
    end
    alias_method :playstation3?, :ps3?

    def ps4?
      id == :ps4
    end
    alias_method :playstation4?, :ps4?

    def psp?
      id == :psp
    end

    def playstation_vita?
      id == :psvita
    end
    alias_method :vita?, :playstation_vita?
    alias_method :psp_vita?, :playstation_vita?

    def kindle?
      id == :kindle || kindle_fire?
    end

    def kindle_fire?
      id == :kindle_fire
    end

    def nintendo_wii?
      id == :wii
    end
    alias_method :wii?, :nintendo_wii?

    def nintendo_wiiu?
      id == :wiiu
    end
    alias_method :wiiu?, :nintendo_wiiu?

    def blackberry_playbook?
      id == :playbook
    end
    alias_method :playbook?, :blackberry_playbook?

    def surface?
      id == :surface
    end

    def tv?
      id == :tv
    end

    # Detect if browser is Silk.
    def silk?
      ua =~ /Silk/
    end

    # Detect if browser is running under Xbox.
    def xbox?
      ua =~ /Xbox/
    end

    # Detect if browser is running under Xbox 360.
    def xbox_360?
      id == :xbox_360
    end

    # Detect if browser is running under Xbox One.
    def xbox_one?
      id == :xbox_one
    end

    # Detect if browser is running under PlayStation.
    def playstation?
      ps3? || ps4?
    end

    # Detect if browser is Nintendo.
    def nintendo?
      wii? || wiiu?
    end

    # Detect if browser is console (currently Xbox, PlayStation, or Nintendo).
    def console?
      xbox? || playstation? || nintendo?
    end

    private

    # Regex taken from http://detectmobilebrowsers.com
    # rubocop:disable Metrics/LineLength
    def detect_mobile?
      psp? ||
        /zunewp7/i.match(ua) ||
        /(android|bb\d+|meego).+mobile|avantgo|bada\/|blackberry|blazer|compal|elaine|fennec|hiptop|iemobile|ip(hone|od)|iris|kindle|lge |maemo|midp|mmp|mobile.+firefox|netfront|opera m(ob|in)i|palm( os)?|phone|p(ixi|re)\/|plucker|pocket|psp|series(4|6)0|symbian|treo|up\.(browser|link)|vodafone|wap|windows ce|xda|xiino/i.match(ua) ||
        /1207|6310|6590|3gso|4thp|50[1-6]i|770s|802s|a wa|abac|ac(er|oo|s\-)|ai(ko|rn)|al(av|ca|co)|amoi|an(ex|ny|yw)|aptu|ar(ch|go)|as(te|us)|attw|au(di|\-m|r |s )|avan|be(ck|ll|nq)|bi(lb|rd)|bl(ac|az)|br(e|v)w|bumb|bw\-(n|u)|c55\/|capi|ccwa|cdm\-|cell|chtm|cldc|cmd\-|co(mp|nd)|craw|da(it|ll|ng)|dbte|dc\-s|devi|dica|dmob|do(c|p)o|ds(12|\-d)|el(49|ai)|em(l2|ul)|er(ic|k0)|esl8|ez([4-7]0|os|wa|ze)|fetc|fly(\-|_)|g1 u|g560|gene|gf\-5|g\-mo|go(\.w|od)|gr(ad|un)|haie|hcit|hd\-(m|p|t)|hei\-|hi(pt|ta)|hp( i|ip)|hs\-c|ht(c(\-| |_|a|g|p|s|t)|tp)|hu(aw|tc)|i\-(20|go|ma)|i230|iac( |\-|\/)|ibro|idea|ig01|ikom|im1k|inno|ipaq|iris|ja(t|v)a|jbro|jemu|jigs|kddi|keji|kgt( |\/)|klon|kpt |kwc\-|kyo(c|k)|le(no|xi)|lg( g|\/(k|l|u)|50|54|\-[a-w])|libw|lynx|m1\-w|m3ga|m50\/|ma(te|ui|xo)|mc(01|21|ca)|m\-cr|me(rc|ri)|mi(o8|oa|ts)|mmef|mo(01|02|bi|de|do|t(\-| |o|v)|zz)|mt(50|p1|v )|mwbp|mywa|n10[0-2]|n20[2-3]|n30(0|2)|n50(0|2|5)|n7(0(0|1)|10)|ne((c|m)\-|on|tf|wf|wg|wt)|nok(6|i)|nzph|o2im|op(ti|wv)|oran|owg1|p800|pan(a|d|t)|pdxg|pg(13|\-([1-8]|c))|phil|pire|pl(ay|uc)|pn\-2|po(ck|rt|se)|prox|psio|pt\-g|qa\-a|qc(07|12|21|32|60|\-[2-7]|i\-)|qtek|r380|r600|raks|rim9|ro(ve|zo)|s55\/|sa(ge|ma|mm|ms|ny|va)|sc(01|h\-|oo|p\-)|sdk\/|se(c(\-|0|1)|47|mc|nd|ri)|sgh\-|shar|sie(\-|m)|sk\-0|sl(45|id)|sm(al|ar|b3|it|t5)|so(ft|ny)|sp(01|h\-|v\-|v )|sy(01|mb)|t2(18|50)|t6(00|10|18)|ta(gt|lk)|tcl\-|tdg\-|tel(i|m)|tim\-|t\-mo|to(pl|sh)|ts(70|m\-|m3|m5)|tx\-9|up(\.b|g1|si)|utst|v400|v750|veri|vi(rg|te)|vk(40|5[0-3]|\-v)|vm40|voda|vulc|vx(52|53|60|61|70|80|81|83|85|98)|w3c(\-| )|webc|whit|wi(g |nc|nw)|wmlb|wonu|x700|yas\-|your|zeto|zte\-/i.match(ua[0..3])
    end
    # rubocop:enable Metrics/LineLength

    def platform
      @platform ||= Platform.new(ua)
    end
  end
end
