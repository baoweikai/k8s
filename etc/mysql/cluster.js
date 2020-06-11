// mysqlsh -hmysql-0.mysql.default.svc.cluster.local -uroot -phuaren54321 // 登录到主mysql
// dba.help('configureInstance') // 查看命令x详情
// 初始化配置所有实例
var replicas = 3
var n = 0
while(n < replicas){
	// dba.configureInstance('root@mysql-' + n + '.mysql:3306', {clusterAdmin:"'root'@'%'",clusterAdminPassword:'huaren54321',password:'huaren54321','restart': true, interactive: false}) // 配置实例集群	
	dba.configureInstance('root@mysql-' + n + '.mysql:3306', {password:'huaren54321', interactive: false}) // 配置实例集群	
	// dba.checkInstanceConfiguration('root@mysql-' + n + '.mysql:3306', {password:'huaren54321','restart': true, interactive: false})      // 校验实例配置
	n++
}
shell.connect('root@mysql-0.mysql:3306', 'huaren54321') // 连接到主节点
// 创建集群
var cluster = dba.createCluster('MyCluster', {interactive: false, localAddress: 'mysql-0.mysql:33061'}) // 创建集群
// cluster.describe(); // 集群信息
// 获取集群信息
// var cluster = dba.getCluster()    // 获取集群信息
// cluster.status()                  // 集群状态查看

n = 1
while(n < replicas){
	cluster.addInstance('root@mysql-' + n + '.mysql.default.svc.cluster.local:3306', {password:'huaren54321'})
	n++
}
// dba.dropMetadataSchema({force: false}) // 删除集群信息（最后使用）
// cluster.removeInstance('root@mysql-0.mysql.default.svc.cluster.local:3306') // 移调实例

/*********参数解析 **********、
------configureInstance------
- mycnfPath: mysql配置文件
- outputMycnfPath: Alternative output path to write the MySQL
- password: mysql密码
- clusterAdmin: 集群账户名
- clusterAdminPassword: 集群账户对应密码
- clearReadOnly: boolean value used to confirm that super_read_only must be disabled.
- interactive: 是否出现交互提示框
- restart: 配置完毕是否重启
SELECT VARIABLE_NAME FROM performance_schema.variables_info ORDER BY VARIABLE_NAME;
*/
