module config
import os

pub struct RegexSetting {
pub mut:
	regex string
	color int
	whitelist_styles []int
}

pub struct Lexer {
pub mut:
	name string
	regexes []RegexSetting
	excluded_styles []int
}

pub struct Config {
pub mut:
	all map[string]Lexer
	use_rgb_format bool
}

pub fn read(config_file string) {
	content := os.read_file(config_file) or { return }
	lines := content.split_into_lines()
	mut lexer := Lexer{}
	mut setting := RegexSetting{}
	p.lexers_to_enhance = Config{}

	for line in lines {
		mut line_ := line.trim(' ')
		if line_.starts_with(';') || line.len < 3 {  // the minimum length is something like 5=A
			continue
		}
		else if line_.starts_with('[') {
			if lexer.name != '' {
				p.lexers_to_enhance.all[lexer.name] = lexer
				lexer = Lexer{}  // new lexer, resets everything
			}
			lexer.name = line_.trim("[]").trim(' ').to_lower()
			setting = RegexSetting{}
		}
		else if line_.starts_with('indicator_id') {
			indicator_id := line_.split('=')
			if indicator_id.len == 2 {
				indicator_id_ := indicator_id[1].trim(' ')
				if p.indicator_id == -1 {
					p.indicator_id = indicator_id_.int()
				}
			}
		}
		else if line_.starts_with('offset') {
			offset := line_.split('=')
			if offset.len == 2 {
				p.offset = offset[1].trim(' ').int()
			}
		}
		else if line_.starts_with('regex_error_style_id') {
			regex_error_style_id := line_.split('=')
			if regex_error_style_id.len == 2 {
				p.regex_error_style_id = regex_error_style_id[1].trim(' ').int()
			}
		}
		else if line_.starts_with('regex_error_color') {
			regex_error_color := line_.split('=')
			if regex_error_color.len == 2 {
				p.regex_error_color = regex_error_color[1].trim(' ').int()
			}
		}
		else if line_.starts_with('use_rgb_format') {
			use_rgb_format := line_.split('=')
			if use_rgb_format.len == 2 {
				val := use_rgb_format[1].trim(' ').int()
				if val == 1 {
					p.lexers_to_enhance.use_rgb_format = true
				}
			}
		}
		else {
			if line_.starts_with('excluded_styles') {
				excludes := line_.split('=')
				if excludes.len == 2 {
					ids := excludes[1].split(',')
					for id in ids {
						trimmed_id := id.trim(' ')
						lexer.excluded_styles << trimmed_id.int()
					}
				}
			} else {
				// the line starts with a color
				split_pos := line_.index('=') or { continue }
				if split_pos > 0 {
					color__ := line_[0..split_pos].trim(' ')
					whitelist_str := color__.find_between('[', ']')
					if whitelist_str.len > 0 {
						setting.whitelist_styles = whitelist_str.split(",").map(int(it.trim_space().parse_int(10, 32) or { -1 }))
					} else {
						setting.whitelist_styles.clear()
					}

					setting.color = color__.replace('#', '0x').int()
					regex := line_[split_pos..].trim_left('=').trim(' ')
					if regex.len > 0 {
						setting.regex = regex
						lexer.regexes << setting
					}
				}
			}
		}
	}
	if lexer.name != '' {
		p.lexers_to_enhance.all[lexer.name] = lexer
	}
	if p.lexers_to_enhance.use_rgb_format {
		// convert back to bgr format
		for _, mut lexer__ in p.lexers_to_enhance.all {
			for i, mut regex in lexer__.regexes {
				bgr_color := rgb_to_bgr(regex.color)
				regex.color = bgr_color
				lexer__.regexes[i] = regex
			}
		}
	}
}

pub fn rgb_to_bgr(rgb int) int {
	red := (rgb >> 16) & 0xFF
	green := (rgb >> 8) & 0xFF
	blue := rgb & 0xFF
	bgr := (blue << 16) | (green << 8) | red
	return bgr
}