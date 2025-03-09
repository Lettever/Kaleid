#include <iostream>
#include <optional>
#include <ctype.h>

enum class TokenType {
    // Identifiers and Keywords
    Identifier,
    Keyword,

    // Literals
    Integer,
    Float,
    String,
    Character,

    // Operators
    Dot,
    And,
    Or,
    Bang,
    Equals,
    EqualsEquals,       // ==
    NotEquals,          // !=
    LessThan,
    GreaterThan,
    LessThanOrEquals,
    GreaterThanOrEquals,

    Assign,
    Plus,
    PlusEquals,
    Minus,
    MinusEquals,
    Times,
    TimesEquals,
    Divide,
    DivideEquals,

    Range,
    InclusiveRange,      // ..=

    // Punctuation
    L_Paren,
    R_Paren,
    L_Brace,
    R_Brace,
    L_Bracket,
    R_Bracket,
    Semicolon,

    // Special
    Unknown,
    Eof,
};

struct Token {
	std::string span;
	TokenType type;
	Token(const std::string& span, TokenType type): span(span), type(type) {}
};

class Lexer {
public:
	std::string source;
	size_t i;
	std::optional<char> peek(size_t a) {
		if (i + a >= source.length()) return std::nullopt;
		return source[i + a];
	}
	std::optional<Token> makeAndAdvance(const std::string& span, TokenType type) {
		i += span.length();
		return Token(span, type);
	}
	
	std::optional<Token> handleMultiCharOp(std::string_view op, char expectedChar, TokenType singleType, TokenType multiType) {
		char nextCh = this->peek(1).value_or('\0');
        if (nextCh == expectedChar) {
            return makeAndAdvance(std::string(op) + expectedChar, multiType);
        }
        return makeAndAdvance(std::string(op), singleType);
	}
	
	std::optional<Token> lexLineComment() {
		std::cout << "TODO! " << __func__ << "\n";
		return this->next();
	}
	
	std::optional<Token> lexMultiLineComment() {
		std::cout << "TODO! " << __func__ << "\n";
		return this->next();
	}
	
	std::optional<Token> lexNumber() {
		std::cout << "TODO! " << __func__ << "\n";
		return this->next();
	}
	
	std::optional<Token> lexAlpha() {
		std::cout << "TODO! " << __func__ << "\n";
		return this->next();
	}
	
	std::optional<Token> lexWhite() {
		std::cout << "TODO! " << __func__ << "\n";
		return this->next();
	}
	
	std::optional<Token> next() {
		if (i >= source.length()) return std::nullopt;
		char ch = source[i];
		if (ch == '+') {
			// +, +=
			return handleMultiCharOp("+", '=', TokenType::Plus, TokenType::PlusEquals);
		} else if (ch == '-') {
			// -, -=
			return handleMultiCharOp("-", '=', TokenType::Minus, TokenType::MinusEquals);
		} else if (ch == '*') {
			// *, *=
			return handleMultiCharOp("*", '=', TokenType::Times, TokenType::TimesEquals);
		} else if (ch == '/') {
			// /, /= //, /*
			char nextCh = this->peek(1).value_or('\0');
			if (nextCh == '/') return lexLineComment();
			if(nextCh == '*') return lexMultiLineComment();
			return handleMultiCharOp("/", '=', TokenType::Divide, TokenType::DivideEquals);
		} else if (ch == '&') {
			// &&
			char nextCh = this->peek(1).value_or('\0');
			if (nextCh != '&') return makeAndAdvance("&" + nextCh, TokenType::Unknown);
			return makeAndAdvance("&&", TokenType::And);
		} else if (ch == '|') {
			char nextCh = this->peek(1).value_or('\0');
			if (nextCh != '|') return makeAndAdvance("&" + nextCh, TokenType::Unknown);
			return makeAndAdvance("||", TokenType::Or);
			// ||
		} else if (ch == '!') {
			// !, !=
			return handleMultiCharOp("!", '=', TokenType::Bang, TokenType::NotEquals);
		} else if (ch == '.') {
			// ., .., ..=
			char nextCh1 = this->peek(1).value_or('\0');
			if (nextCh1 != '.') return makeAndAdvance(".", TokenType::Dot);
			char nextCh2 = this->peek(2).value_or('\0');
			if (nextCh2 != '=') return makeAndAdvance("..", TokenType::Range);
			return makeAndAdvance("..=", TokenType::InclusiveRange);
		} else  if (ch == '=') {
			//=, ==
			return handleMultiCharOp("=", '=', TokenType::Equals, TokenType::EqualsEquals);
		} else if (ch == '<') {
			// <, <=
			return handleMultiCharOp("<", '=', TokenType::LessThan, TokenType::LessThanOrEquals);
		} else if (ch == '>') {
			// >, >=
			return handleMultiCharOp(">", '=', TokenType::GreaterThan, TokenType::GreaterThanOrEquals);
		} else if (ch == '(') {
			return makeAndAdvance("(", TokenType::L_Paren);
		} else if (ch == ')') {
			return makeAndAdvance(")", TokenType::R_Paren);
		} else if (ch == '{') {
			return makeAndAdvance("{", TokenType::L_Brace);
		} else if (ch == '}') {
			return makeAndAdvance("}", TokenType::R_Brace);
		} else if (ch == '[') {
			return makeAndAdvance("[", TokenType::L_Bracket);
		} else if (ch == ']') {
			return makeAndAdvance("]", TokenType::R_Bracket);
		} else if (ch == ';') {
			return makeAndAdvance(";", TokenType::Semicolon);
		} else if (isdigit(ch)) {
			return lexNumber();
		} else if (isalpha(ch)) {
			return lexAlpha();
		} else if (iswhite(ch)) {
			return lexWhite();
		}
		return Token("", TokenType::Eof);
	}
//public:
	Lexer(const std::string& input): source(input), i(0) { }
	
};

struct Person {
	int age;
	std::string name;
	static void hello() {
		std::cout << "Hello form Person\n";
	}
};

std::ostream& operator<<(std::ostream& os, const Person& p) {
	os << "Name: " << p.name << ", Age: " << p.age;
	return os;
}

int main() {
	
}
