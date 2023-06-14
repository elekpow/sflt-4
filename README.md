# Домашнее задание к занятию  <br>  ***«Отказоустойчивость в облаке» - Левин Игорь***

### Цель задания

В результате выполнения этого задания вы научитесь:  
1. Конфигурировать отказоустойчивый кластер в облаке с использованием различных функций отказоустойчивости. 
2. Устанавливать сервисы из конфигурации инфраструктуры.

------

### Чеклист готовности к домашнему заданию

1. Создан аккаунт на YandexCloud.  
2. Создан новый OAuth-токен.  
3. Установлено программное обеспечение  Terraform.   


### Инструменты и дополнительные материалы, которые пригодятся для выполнения задания

1. [Документация сетевого балансировщика нагрузки](https://cloud.yandex.ru/docs/network-load-balancer/quickstart)

 ---

## Задание 1 

Возьмите за основу [решение к заданию 1 из занятия «Подъём инфраструктуры в Яндекс Облаке»](https://github.com/netology-code/sdvps-homeworks/blob/main/7-03.md#задание-1).
1. Теперь вместо одной виртуальной машины сделайте terraform playbook, который:
- создаст 2 идентичные виртуальные машины. Используйте аргумент [count](https://www.terraform.io/docs/language/meta-arguments/count.html) для создания таких ресурсов;
- создаст [таргет-группу](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/lb_target_group). Поместите в неё созданные на шаге 1 виртуальные машины;
- создаст [сетевой балансировщик нагрузки](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/lb_network_load_balancer), который слушает на порту 80, отправляет трафик на порт 80 виртуальных машин и http healthcheck на порт 80 виртуальных машин.
Рекомендуем изучить [документацию сетевого балансировщика нагрузки](https://cloud.yandex.ru/docs/network-load-balancer/quickstart) для того, чтобы было понятно, что вы сделали.
2. Установите на созданные виртуальные машины пакет Nginx любым удобным способом и запустите Nginx веб-сервер на порту 80.
3. Перейдите в веб-консоль Yandex Cloud и убедитесь, что: 
- созданный балансировщик находится в статусе Active,
- обе виртуальные машины в целевой группе находятся в состоянии healthy.
4. Сделайте запрос на 80 порт на внешний IP-адрес балансировщика и убедитесь, что вы получаете ответ в виде дефолтной страницы Nginx.

*В качестве результата пришлите:*

*1. Terraform Playbook.

*2. Скриншот статуса балансировщика и целевой группы.*

*3. Скриншот страницы, которая открылась при запросе IP-адреса балансировщика.*

----

### Выполнения задания 1

Через terraform создаем 2 идентичные виртуальные машины, содаем таргет группу и сетевой балансировщик нагрузки

[Terraform Playbook ](https://github.com/elekpow/sflt-4/blob/main/sflt-4/main.tf)

[Terraform metadata ](https://github.com/elekpow/sflt-4/blob/main/sflt-4/metadata.yaml)

в varibles определяется количество виртуальных машин и  задаются имена

[Terraform variables ](https://github.com/elekpow/sflt-4/blob/main/sflt-4/variables.tf)


Также через Terraform , применяя runcmd устанавлвиваем nginx , и в index.html прописываем имя и ip адрес виртуальной машины

```
packages:
  - nginx

runcmd:
  - cp /var/www/html/index.nginx-debian.html /var/www/html/index.html
  - echo "$(hostname | awk ' {print $1 " | <br/>"}') " >> /var/www/html/index.html
  - echo "$(ip address | grep "inet " | awk ' {print $4,"(", $2,")","| <br/>"}') " >> /var/www/html/index.html
  - service nginx reload

```

Веб-консоль Yandex Cloud:

Балансер

![balancer.JPG](https://github.com/elekpow/sflt-4/blob/main/sflt-4/balancer.JPG)

Группа

![group.JPG](https://github.com/elekpow/sflt-4/blob/main/sflt-4/group.JPG)

система работает , для примера открыта старница в браузере и одновременно в режиме инкогнито

![page1.JPG](https://github.com/elekpow/sflt-4/blob/main/sflt-4/page1.JPG)


![page2.JPG](https://github.com/elekpow/sflt-4/blob/main/sflt-4/page2.JPG)


---

## Задания со звёздочкой*
Эти задания дополнительные. Выполнять их не обязательно. На зачёт это не повлияет. Вы можете их выполнить, если хотите глубже разобраться в материале.

---

## Задание 2*

1. Теперь вместо создания виртуальных машин создайте [группу виртуальных машин с балансировщиком нагрузки](https://cloud.yandex.ru/docs/compute/operations/instance-groups/create-with-balancer).

2. Nginx нужно будет поставить тоже автоматизированно. Для этого вам нужно будет подложить файл установки Nginx в user-data-ключ [метадаты](https://cloud.yandex.ru/docs/compute/concepts/vm-metadata) виртуальной машины.

- [Пример файла установки Nginx](https://github.com/nar3k/yc-public-tasks/blob/master/terraform/metadata.yaml).
- [Как подставлять файл в метадату виртуальной машины.](https://github.com/nar3k/yc-public-tasks/blob/a6c50a5e1d82f27e6d7f3897972adb872299f14a/terraform/main.tf#L38)

3. Перейдите в веб-консоль Yandex Cloud и убедитесь, что: 

- созданный балансировщик находится в статусе Active,
- обе виртуальные машины в целевой группе находятся в состоянии healthy.

4. Сделайте запрос на 80 порт на внешний IP-адрес балансировщика и убедитесь, что вы получаете ответ в виде дефолтной страницы Nginx.

*В качестве результата пришлите*

*1. Terraform Playbook.*

*2. Скриншот статуса балансировщика и целевой группы.*

*3. Скриншот страницы, которая открылась при запросе IP-адреса балансировщика.*

----

### Выполнения задания 2