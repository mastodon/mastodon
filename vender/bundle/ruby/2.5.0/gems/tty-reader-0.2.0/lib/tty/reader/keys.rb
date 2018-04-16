# encoding: utf-8
# frozen_string_literal: true

module TTY
  class Reader
    # Mapping of escape codes to keys
    module Keys
      def ctrl_keys
        {
          ?\C-a => :ctrl_a,
          ?\C-b => :ctrl_b,
          ?\C-c => :ctrl_c,
          ?\C-d => :ctrl_d,
          ?\C-e => :ctrl_e,
          ?\C-f => :ctrl_f,
          ?\C-g => :ctrl_g,
          ?\C-h => :ctrl_h, # identical to '\b'
          ?\C-i => :ctrl_i, # identical to '\t'
          ?\C-j => :ctrl_j, # identical to '\n'
          ?\C-k => :ctrl_k,
          ?\C-l => :ctrl_l,
          ?\C-m => :ctrl_m, # identical to '\r'
          ?\C-n => :ctrl_n,
          ?\C-o => :ctrl_o,
          ?\C-p => :ctrl_p,
          ?\C-q => :ctrl_q,
          ?\C-r => :ctrl_r,
          ?\C-s => :ctrl_s,
          ?\C-t => :ctrl_t,
          ?\C-u => :ctrl_u,
          ?\C-v => :ctrl_v,
          ?\C-w => :ctrl_w,
          ?\C-x => :ctrl_x,
          ?\C-y => :ctrl_y,
          ?\C-z => :ctrl_z,
          ?\C-@ => :ctrl_space,
          ?\C-| => :ctrl_backslash, # both Ctrl-| & Ctrl-\
          ?\C-] => :ctrl_square_close,
          "\e[1;5A" => :ctrl_up,
          "\e[1;5B" => :ctrl_down,
          "\e[1;5C" => :ctrl_right,
          "\e[1;5D" => :ctrl_left
        }
      end
      module_function :ctrl_keys

      def keys
        {
          "\t" => :tab,
          "\n" => :enter,
          "\r" => :return,
          "\e" => :escape,
          " "  => :space,
          "\x7F"  => :backspace,
          "\e[1~" => :home,
          "\e[2~" => :insert,
          "\e[3~" => :delete,
          "\e[3;2~" => :shift_delete,
          "\e[3;5~" => :ctrl_delete,
          "\e[4~" => :end,
          "\e[5~" => :page_up,
          "\e[6~" => :page_down,
          "\e[7~" => :home, # xrvt
          "\e[8~" => :end, # xrvt

          "\e[A" => :up,
          "\e[B" => :down,
          "\e[C" => :right,
          "\e[D" => :left,
          "\e[E" => :clear,
          "\e[H" => :home,
          "\eOH" => :home,
          "\e[F" => :end,
          "\eOF" => :end,
          "\e[Z" => :back_tab, # shift + tab

          "\eOP" => :f1,
          "\eOQ" => :f2,
          "\eOR" => :f3,
          "\eOS" => :f4,
          "\e[[A" => :f1, # linux
          "\e[[B" => :f2, # linux
          "\e[[C" => :f3, # linux
          "\e[[D" => :f4, # linux
          "\e[[E" => :f5, # linux
          "\e[11~" => :f1, # rxvt-unicode
          "\e[12~" => :f2, # rxvt-unicode
          "\e[13~" => :f3, # rxvt-unicode
          "\e[14~" => :f4, # rxvt-unicode
          "\e[15~" => :f5,
          "\e[17~" => :f6,
          "\e[18~" => :f7,
          "\e[19~" => :f8,
          "\e[20~" => :f9,
          "\e[21~" => :f10,
          "\e[23~" => :f11,
          "\e[24~" => :f12,
          "\e[25~" => :f13,
          "\e[26~" => :f14,
          "\e[28~" => :f15,
          "\e[29~" => :f16,
          "\e[31~" => :f17,
          "\e[32~" => :f18,
          "\e[33~" => :f19,
          "\e[34~" => :f20,
          # xterm
          "\e[1;2P" => :f13,
          "\e[2;2Q" => :f14,
          "\e[1;2S"  => :f16,
          "\e[15;2~" => :f17,
          "\e[17;2~" => :f18,
          "\e[18;2~" => :f19,
          "\e[19;2~" => :f20,
          "\e[20;2~" => :f21,
          "\e[21;2~" => :f22,
          "\e[23;2~" => :f23,
          "\e[24;2~" => :f24,

          "\eOA" => :up,
          "\eOB" => :down,
          "\eOC" => :right,
          "\eOD" => :left
        }
      end
      module_function :keys

      def win_keys
        {
          "\t" => :tab,
          "\n" => :enter,
          "\r" => :return,
          "\e" => :escape,
          " "  => :space,
          "\b" => :backspace,
          [224, 71].pack('U*') => :home,
          [224, 79].pack('U*') => :end,
          [224, 82].pack('U*') => :insert,
          [224, 83].pack('U*') => :delete,
          [224, 73].pack('U*') => :page_up,
          [224, 81].pack('U*') => :page_down,

          [224, 72].pack('U*') => :up,
          [224, 80].pack('U*') => :down,
          [224, 77].pack('U*') => :right,
          [224, 75].pack('U*') => :left,
          [224, 83].pack('U*') => :clear,

          "\x00;" => :f1,
          "\x00<" => :f2,
          "\x00"  => :f3,
          "\x00=" => :f4,
          "\x00?" => :f5,
          "\x00@" => :f6,
          "\x00A" => :f7,
          "\x00B" => :f8,
          "\x00C" => :f9,
          "\x00D" => :f10,
          "\x00\x85" => :f11,
          "\x00\x86" => :f12
        }
      end
      module_function :win_keys
    end # Keys
  end # Reader
end # TTY
