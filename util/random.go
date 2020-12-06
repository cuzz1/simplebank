package util

import (
	"math/rand"
	"strings"
	"time"
)

const alphabet = "abcdefghijklmnopqrstuvwxyz"

// init()函数会在每个包完成初始化后自动执行，并且执行优先级比main函数高。init 函数通常被用来：
// 1. 对变量进行初始化
// 2. 检查/修复程序的状态
// 3. 注册
// 4. 运行一次计算
func init() {
	rand.Seed(time.Now().UnixNano())
}

// RandomInt 随机生成一个数在 [min, max] 之间
func RandomInt(min, max int64) int64 {
	return min + rand.Int63n(max-min+1)
}

// RandomString 随机生成长度为 n 的字符串
func RandomString(n int) string {
	var sb strings.Builder
	l := len(alphabet)
	for i := 0; i < n; i++ {
		c := alphabet[rand.Intn(l)]
		sb.WriteByte(c)
	}
	return sb.String()
}

// RandomOwner generates a random owner name
func RandomOwner() string {
	return RandomString(6)
}

// RandomMoney generates a random amount of money
func RandomMoney() int64 {
	return RandomInt(0, 1000)
}

// RandomCurrency generates a random currency code
func RandomCurrency() string {
	currencies := []string{"CNY", "USD", "EUR"}
	n := len(currencies)
	return currencies[rand.Intn(n)]
}
