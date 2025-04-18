#include <iostream>
#include <optional>
#include <ctype.h>
#include <map>
#include <unordered_map>
#include <unordered_set>
#include <functional>
#include <cassert>
#include <string>
#include <string_view>

enum class TokenType {
    // Identifiers and Keywords
    Identifier,
    Keyword,

    // Literals
    Integer,
    Float,
    SpecialNumber,
    String,

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

std::ostream& operator<<(std::ostream& os, const TokenType& t) {
	switch(t) {
    case TokenType::Identifier: os << "TokenType::Identifier"; break;
    case TokenType::Keyword: os << "TokenType::Keyword"; break;
    case TokenType::Integer: os << "TokenType::Integer"; break;
    case TokenType::Float: os << "TokenType::Float"; break;
    case TokenType::SpecialNumber: os << "TokenType::SpecialNumber"; break;
    case TokenType::String: os << "TokenType::String"; break;
    case TokenType::Dot: os << "TokenType::Dot"; break;
    case TokenType::And: os << "TokenType::And"; break;
    case TokenType::AndAnd: os << "TokenType::AndAnd"; break;
    case TokenType::OrOr: os << "TokenType::OrOr"; break;
    case TokenType::Bang: os << "TokenType::Bang"; break;
    case TokenType::Equals: os << "TokenType::Equals"; break;
    case TokenType::EqualsEquals: os << "TokenType::EqualsEquals"; break;
    case TokenType::NotEquals: os << "TokenType::NotEquals"; break;
    case TokenType::LessThan: os << "TokenType::LessThan"; break;
    case TokenType::GreaterThan: os << "TokenType::GreaterThan"; break;
    case TokenType::LessThanOrEquals: os << "TokenType::LessThanOrEquals"; break;
    case TokenType::GreaterThanOrEquals: os << "TokenType::GreaterThanOrEquals"; break;
    case TokenType::Plus: os << "TokenType::Plus"; break;
    case TokenType::PlusEquals: os << "TokenType::PlusEquals"; break;
    case TokenType::Minus: os << "TokenType::Minus"; break;
    case TokenType::MinusEquals: os << "TokenType::MinusEquals"; break;
    case TokenType::Times: os << "TokenType::Times"; break;
    case TokenType::TimesEquals: os << "TokenType::TimesEquals"; break;
	case TokenType::Divide: os << "TokenType::Divide"; break;
	case TokenType::DivideEquals: os << "TokenType::DivideEquals"; break;
	case TokenType::LeftArrow: os << "TokenType::LeftArrow"; break;
	case TokenType::Range: os << "TokenType::Range"; break;
	case TokenType::InclusiveRange: os << "TokenType::InclusiveRange"; break;
	case TokenType::L_Paren: os << "TokenType::L_Paren"; break;
	case TokenType::R_Paren: os << "TokenType::R_Paren"; break;
	case TokenType::L_Brace: os << "TokenType::L_Brace"; break;
	case TokenType::R_Brace: os << "TokenType::R_Brace"; break;
	case TokenType::L_Bracket: os << "TokenType::L_Bracket"; break;
	case TokenType::R_Bracket: os << "TokenType::R_Bracket"; break;
	case TokenType::Semicolon: os << "TokenType::Semicolon"; break;
	case TokenType::Unknown: os << "TokenType::Unknown"; break;
	case TokenType::Eof: os << "TokenType::Eof"; break;
	default: os << "TODO " << static_cast<int>(t) << __LINE__; break;
	}
	return os;
}

std::ostream& operator<<(std::ostream& os, const Token& t) {
	std::cout << t.span << " " << t.type;
	return os;
}

std::unordered_set<char> getUniqueCharsFromKeys(std::unordered_map<std::string_view, TokenType> map) {
	std::unordered_set<char> uniqueChars;

    for (const auto& [key, _] : map) {
        for (char ch : key) {
            uniqueChars.insert(ch);
        }
    }

    return uniqueChars;
}

template<typename K, typename V>
std::vector<K> getKeys(const std::unordered_map<K, V>& inputMap) {
    std::vector<K> keys;
    keys.reserve(inputMap.size()); // Pre-allocate memory for efficiency
    
    // Extract keys using range-based for loop
    for (const auto& [key, value] : inputMap) {
        keys.push_back(key);
    }
    
    return keys;
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

bool isHex(char ch) {
	if (isdigit(ch)) return true;
	ch = tolower(ch);
	return ch >= 'a' && ch <= 'f';
}

bool isOctal(char ch) {
    return ch >= '0' && ch <= '7';
}

bool isBinary(char ch) {
    return ch >= '0' && ch <= '1';
}

size_t getLargestOperatorSize(const std::vector<std::string_view>& operators) {
	size_t maxSize = 0;
	for (const auto& op : operators) {
        maxSize = std::max(maxSize, op.size());
    }
    return maxSize;
}
        
std::vector<std::unordered_map<std::string, TokenType>>
groupOperatorsByDecreasingSize(std::unordered_map<std::string_view, TokenType> tokenMap) {
	size_t maxSize = getLargestOperatorSize(getKeys(tokenMap));
	std::vector<std::unordered_map<std::string, TokenType>> res(maxSize);
	for (const auto& [k, v] : tokenMap) {
        res[maxSize - k.size()].emplace(k, v);
    }
	return res;
}

class Lexer {
public:
	const std::unordered_map<std::string_view, TokenType> tokenMap = {
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
    const std::unordered_set<char> operatorChars = getUniqueCharsFromKeys(tokenMap);
    const std::vector<std::unordered_map<std::string, TokenType>> sortedOperators = groupOperatorsByDecreasingSize(tokenMap);
	std::string source;
	size_t i;

	std::optional<char> peek(size_t n);
	std::optional<char> absolutePeek(size_t j);
	Token makeAndAdvance(const std::string& span, TokenType type);
	std::optional<Token> lexLineComment();
	std::optional<Token> lexMultiLineComment();
	std::optional<Token> lexSpecialNumber();
	bool shouldLexSpecialNumber();
	std::optional<Token> lexNumber();
	Token lexAlpha();
	std::optional<Token> lexWhite();
	Token lexOperator();
	std::optional<Token> next();
	bool isOperator(std::string_view view);
	bool isOperator(char ch);
	Lexer(const std::string& input): source(input), i(0) { };
};

std::optional<char> Lexer::peek(size_t n) {
	if (i + n >= source.length()) return std::nullopt;
	return source[i + n];
}

std::optional<char> Lexer::absolutePeek(size_t j) {
	if (j >= source.length()) return std::nullopt;
	return source[j];
}

Token Lexer::makeAndAdvance(const std::string& span, TokenType type) {
	i += span.length();
	return Token(span, type);
}

std::optional<Token> Lexer::lexLineComment() {
	i = advanceWhile(source, i, [](char ch) { return ch != '\n'; });
	return this->next();
}

std::optional<Token> Lexer::lexMultiLineComment() {
	int level = 1;
	i += 2;
	while (i < source.length() && (level != 0)) {
		char nextCh = this->peek(1).value_or('\0');
		if (source[i] == '*' && nextCh == '/') level -= 1;
		else if (source[i] == '/' && nextCh == '*') level += 1;
		i += 1;
	}
	i += 1;
	return this->next();
}

std::optional<Token> Lexer::lexSpecialNumber() {
	char nextCh = tolower(this->peek(1).value_or('\0'));
	static const std::map<char, std::function<bool(int)>> mp = {
		{ 'x', isHex },
		{ 'o', isOctal },
		{ 'b', isBinary },
	};
	
	if (!mp.contains(nextCh)) {
		return makeAndAdvance("0", TokenType::Integer);
	}
	
	size_t j = advanceWhile(source, i + 2, mp.at(nextCh));
	std::string str = source.substr(i, j - i);
	if (i + 2 == j) return makeAndAdvance(str, TokenType::Unknown);
	return makeAndAdvance(str, TokenType::SpecialNumber);
}

bool Lexer::shouldLexSpecialNumber() {
	char nextCh = this->peek(1).value_or('\0');
	return source[i] == '0' && (nextCh != '.');
}
	
std::optional<Token> Lexer::lexNumber() {
	if (shouldLexSpecialNumber()) return lexSpecialNumber();
	bool isFloat = false;
	size_t j = advanceWhile(source, i, isdigit); //get integer part
	char nextCh = this->absolutePeek(j).value_or('\0');
	if (nextCh == '.') {
		isFloat = true;
		j += 1;
		if (!isdigit(this->absolutePeek(j).value_or('\0'))) {
			return makeAndAdvance(source.substr(i, j - i), TokenType::Unknown);
		}
		j = advanceWhile(source, j, isdigit); // get decimal numbers
	}
	nextCh = this->absolutePeek(j).value_or('\0');
	if (nextCh == 'e' || nextCh == 'E') {
		isFloat = true;
		j += 1;
		char ch = this->absolutePeek(j).value_or('\0');
		if (ch == '-' || ch == '+') j += 1;
		if (!isdigit(this->absolutePeek(j).value_or('\0'))) {
			return makeAndAdvance(source.substr(i, j - i), TokenType::Unknown);
		}
		j = advanceWhile(source, j, isdigit);
	}
	
	std::string str = source.substr(i, j - i);
	if (isFloat) return makeAndAdvance(str, TokenType::Float);
	return makeAndAdvance(str, TokenType::Integer);
}

Token Lexer::lexAlpha() {
	size_t j = advanceWhile(source, i, [](char ch){ return isalnum(ch) || (ch == '_'); });
	std::string lexedString = source.substr(i, j - i);
	TokenType type = isKeyword(lexedString) ? TokenType::Keyword : TokenType::Identifier;
	return makeAndAdvance(lexedString, type);
}

std::optional<Token> Lexer::lexWhite() {
	i = advanceWhile(source, i, isspace);
	return this->next();
}

Token Lexer::lexOperator() {
	size_t len = 1;
	while (isOperator(source.substr(i, len + 1))) {
        len += 1;
	}
	std::string op = source.substr(i, len);
	return makeAndAdvance(op, tokenMap.at(op));
}

bool Lexer::isOperator(std::string_view view) {
    return tokenMap.contains(view);
}

bool Lexer::isOperator(char ch) {
    return operatorChars.contains(ch);
}

    //return true;
std::optional<Token> Lexer::next() {
	if (i >= source.length()) return Token("", TokenType::Eof);;
	char ch = source[i];
	char nextCh = this->peek(1).value_or('\0');

	if (ch == '/' && nextCh == '/') return lexLineComment();
	else if (ch == '/' && nextCh == '*') return lexMultiLineComment();
	else if (isdigit(ch)) return lexNumber();
	else if (isalpha(ch) || ch == '_') return lexAlpha();
	else if (isspace(ch)) return lexWhite();
	else if (isOperator(ch)) return lexOperator();
	else return makeAndAdvance(std::string(1, ch), TokenType::Unknown);
}

int main() {
	//auto l = Lexer("123 456 789.012 1.23e4 1.23e+1 7.16e-6 7.16e- 10e3 0x123 0X1FF 0Xq 0b11112 0B2 0O08");
	auto l = Lexer("hi /*helo*//=+......= /* abc /*q*/w*/");
	std::optional<Token> t = l.next();
	while (t.has_value() && t.value().type != TokenType::Eof) {
		std::cout << t.value() << "\n";
		t = l.next();
	}
	
    // std::cout << map.at("foo") << "\n"; "at" throws an exception if the key does not exists
    // indexing normally returns a default value
    return 0;
}
