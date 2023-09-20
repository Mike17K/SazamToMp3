String shringText(String text, int maxLen) {
  if (text.length <= maxLen) {
    return text;
  }
  return text.substring(0, maxLen) + '...';
}