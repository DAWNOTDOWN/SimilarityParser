重复代码扫描工具similar 使用说明及下载地址：http://www.harukizaemon.com/simian/installation.html#cli 

指定目录下扫描重复代码的参考命令如下：
     java -jar simian-2.5.1.jar -includes=**/*.m **/*.mm -threshold=10 >similar.txt
     
SimilarityParser工程为命令行程序，用于剔除重复代码扫描结果中未出现在Linkmap文件中的项

使用simian时 毋需指定生成结果格式，SimilarityParser分析代码中依赖了simian的默认结果格式

SimilarityParser的使用方法为在main.m中指定重复代码扫描结果 similar.txt及对应linkmap文件LinkMap-arm64.txt所在的目录，运行工程会在指定的目录下生成revised_similar.txt 
