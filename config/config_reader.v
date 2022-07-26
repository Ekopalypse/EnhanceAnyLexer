module config
import os

pub struct RegexSetting {
pub mut:
	regex string
	color int
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
	current Lexer
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
				p.indicator_id = indicator_id_.int()
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
		} else {
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
}
