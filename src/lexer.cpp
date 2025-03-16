#include <iostream>
#include <optional>
#include <ctype.h>
#include <unordered_map>
#include <unordered_set>
#include <functional>
#include <cassert>

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
    AndAnd,
    OrOr,
    Bang,
    Equals,
    EqualsEquals,
    NotEquals,
    LessThan,
    GreaterThan,
    LessThanOrEquals,
    GreaterThanOrEquals,
    Plus,
    PlusEquals,
    Minus,
    MinusEquals,
    Times,
    TimesEquals,
	Divide,
	DivideEquals,
	LeftArrow,
	Range,
	InclusiveRange,

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

std::unordered_set<char> getUniqueCharsFromKeys(std::unordered_map<std::string, TokenType> map) {
	std::unordered_set<char> uniqueChars;

    for (const auto& pair : map) {
        const std::string& key = pair.first;
		for (char ch : key) {
            uniqueChars.insert(ch);
        }
    }

    return uniqueChars;
}

size_t advanceWhile(std::string_view str, size_t i, const std::function<bool(char)>& fn) {
	size_t len = str.size();
	while ((i < len) && fn(str[i])) i += 1;
	return i;
}

bool isKeyword(std::string_view identifier) {
	static const std::unordered_set<std::string_view> keywords = {
		"if", "while", "for", "else",
		"struct", "trait", "fn", "break",
		"continue", "return", "match",
		"use", "module", "assert",
	};
	return keywords.count(identifier) > 0;
}

class Lexer {
public:
	const std::unordered_map<std::string, TokenType> tokenMap = {
		{ ".", TokenType::Dot },
		{ "&", TokenType::And },
		{ "&&", TokenType::AndAnd},
		{ "||", TokenType::OrOr },
		{ "!", TokenType::Bang },
		{ "=", TokenType::Equals },
		{ "==", TokenType::EqualsEquals },
		{ "!=", TokenType::NotEquals },
		{ "<", TokenType::LessThan },
		{ ">", TokenType::GreaterThan },
		{ "<=", TokenType::LessThanOrEquals },
		{ ">=", TokenType::GreaterThanOrEquals },
		{ "+", TokenType::Plus },
		{ "+=", TokenType::PlusEquals },
		{ "-", TokenType::Minus },
		{ "-=", TokenType::MinusEquals },
		{ "*", TokenType::Times },
		{ "*=", TokenType::TimesEquals },
		{ "/", TokenType::Divide },
		{ "/=", TokenType::DivideEquals },
		{ "->", TokenType::LeftArrow },
		{ "..", TokenType::Range },
		{ "..=", TokenType::InclusiveRange },
		{ "(", TokenType::L_Paren },
		{ ")", TokenType::R_Paren },
		{ "{", TokenType::L_Brace },
		{ "}", TokenType::R_Brace },
		{ "[", TokenType::L_Bracket },
		{ "]", TokenType::R_Bracket },
		{ ";", TokenType::Semicolon },
    };
    const std::unordered_set<char> uniqueChars = getUniqueCharsFromKeys(tokenMap);
	std::string source;
	size_t i;

	std::optional<char> peek(size_t a) {
		if (i + a >= source.length()) return std::nullopt;
		return source[i + a];
	}

	Token makeAndAdvance(const std::string& span, TokenType type) {
		i += span.length();
		return Token(span, type);
	}

	std::optional<Token> lexLineComment() {
		std::cout << "TODO! " << __func__ << "\n";
		std::cout << source[i] << "\n\n";
		i += 1;
		return this->next();
	}

	std::optional<Token> lexMultiLineComment() {
		std::cout << "TODO! " << __func__ << "\n";
		std::cout << source[i] << "\n\n";
		i += 1;
		return this->next();
	}
	
	std::optional<Token> lexNumber() {
		size_t j = advanceWhile(source, i, isdigit);
		char nextCh = this->peek(j - i).value_or('\0');
		if (nextCh != '.') return makeAndAdvance(source.substr(i, j - i), TokenType::Integer);
		size_t k = advanceWhile(source, j + 1, isdigit);
		if (j + 1 == k) return std::nullopt; // There are no numbers after the dot
		return makeAndAdvance(source.substr(i, k - i), TokenType::Float);
	}

	Token lexAlpha() {
		size_t j = advanceWhile(source, i, [](char ch){ return isalnum(ch) || (ch == '_'); });
		std::string lexedString = source.substr(i, j - i);
		TokenType type = isKeyword(lexedString) ? TokenType::Keyword : TokenType::Identifier;
		return makeAndAdvance(lexedString, type);
	}
	
	std::optional<Token> lexWhite() {
		//std::cout << __func__ << "\n";
		i = advanceWhile(source, i, isspace);
		return this->next();
	}

	std::optional<Token> lexOperator() {
		std::cout << "TODO! " << __func__ << "\n";
		std::cout << source[i] << "\n\n";
		i += 1;
		return this->next();
	}
	
	std::optional<Token> next() {
		if (i >= source.length()) return Token("", TokenType::Eof);;
		char ch = source[i];
		char nextCh = this->peek(1).value_or('\0');
		
		if (ch == '/' && nextCh == '/') return lexLineComment();
		else if (ch == '/' && nextCh == '*') return lexMultiLineComment();
		else if (isdigit(ch)) return lexNumber();
		else if (isalpha(ch) || ch == '_') return lexAlpha();
		else if (isspace(ch)) return lexWhite();
		else if (uniqueChars.count(ch)) return lexOperator();
		else return makeAndAdvance(std::string(1, ch), TokenType::Unknown);
	}

	Lexer(const std::string& input): source(input), i(0) { }
};

std::ostream& operator<<(std::ostream& os, const Token& t) {
	std::cout << t.span << " ";
	switch(t.type) {
	case TokenType::Semicolon: os << "TokenType::Semicolon"; break;
	case TokenType::R_Bracket: os << "R_Bracket"; break;
	case TokenType::L_Bracket: os << "TokenType::L_Bracket"; break;
	case TokenType::Integer: os << "TokenType::Integer"; break;
	case TokenType::Float: os << "TokenType::Float"; break;
	case TokenType::Identifier: os << "TokenType::Identifier"; break;
	case TokenType::Keyword: os << "TokenType::Keyword"; break;
	default: os << "TODO " << static_cast<int>(t.type); break;
	}
	return os;
}

int main() {
	auto l = Lexer("123.345 2341111 4.1 anc qwe_q1 _nasd098 if for while");
	std::optional<Token> t = l.next();
	while (t.has_value() && t.value().type != TokenType::Eof) {
		std::cout << t.value() << "\n";
		t = l.next();
	}
	
    // std::cout << map.at("foo") << "\n"; "at" throws an exception if the key does not exists
    // indexing normally returns a default value
    return 0;
}
