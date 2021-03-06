library(N2H4)
# 메인 카테고리 id 가져옵니다.
cate<-getMainCategory()
# 예시를 위해 하나만 선택합니다.
# 여기는 100(정치)를 선택했습니다.
tcate<-cate$sid1[1]
# 정치의 세부 카테고리를 가져옵니다.
subCate<-cbind(sid1=tcate,getSubCategory(sid1=tcate))
# 그중에 1번째, 2번째 세부 카테고리를 정했습니다.
tscate<-subCate$sid2[1:2]

# 목표 날짜를 지정합니다.
strDate<-"20160101"
endDate<-"20160101"

strTime<-Sys.time() # 기록용 타임
midTime<-Sys.time() # 중간 확인용 타임

for (date in strDate:endDate){
  for (sid1 in tcate){
    for (sid2 in tscate){
      
      print(paste0(date," / ",sid1," / ",sid2 ," / start Time: ", strTime," / spent Time: ", Sys.time()-midTime," / spent Time at first: ", Sys.time()-strTime))
      midTime<-Sys.time()
      
      # 뉴스 리스트 페이지의 url을 sid1, sid2, date로 생성합니다.
      pageUrl<-paste0("http://news.naver.com/main/list.nhn?sid2=",sid2,"&sid1=",sid1,"&mid=shm&mode=LS2D&date=",date)
      # 리스트 페이지의 마지막 페이지수를 가져옵니다.
      max<-getMaxPageNum(pageUrl)
      
      for (pageNum in 1:max){
        print(paste0(date," / ",sid1," / ",sid2," / ",pageNum, " / start Time: ", strTime," / spent Time: ", Sys.time()-midTime," / spent Time at first: ", Sys.time()-strTime))
        midTime<-Sys.time()
        # 페이지넘버를 포함한 뉴스 리스트 페이지의 url을 생성합니다.
        pageUrl<-paste0("http://news.naver.com/main/list.nhn?sid2=",sid2,"&sid1=",sid1,"&mid=shm&mode=LS2D&date=",date,"&page=",pageNum)
        # 뉴스 리스트 페이지 내의 개별 네이버 뉴스 url들을 가져옵니다.
        newsList<-getUrlListByCategory(pageUrl)
        newsData<-c()
        
        # 가져온 url들의 정보를 가져옵니다.
        for (newslink in newsList$links){
          ## 불러오기에 성공할 때 까지 반복합니다.
          # 성공할때 까지 반복하면 못나오는 문제가 있어서 5회로 제한합니다.
          tryi<-0
          tem<-try(getContent(newslink), silent = TRUE)
          while(tryi<=5&&class(tem)=="try-error"){
            tem<-try(getContent(newslink), silent = TRUE)
            tryi<-tryi+1
            print(paste0("try again: ",newslink))
          }
          if(class(tem$datetime)[1]=="POSIXct"){
            newsData<-rbind(newsData,tem)
          }
        }
        
        dir.create("./data",showWarnings=F)
        # 가져온 뉴스들(보통 한 페이지에 20개의 뉴스가 있습니다.)을 csv 형태로 저장합니다.
        write.csv(newsData, file=paste0("./data/news",sid1,"_",sid2,"_",date,"_",pageNum,".csv"),row.names = F)
      }
    }
  }
}

# 10년치의 디폴트 값에 대한 선정치 / 또 다른 확인 사항 - 무엇이 카테고리 뉴스에서 기록되야, 크롤러가 되는가?
# 알수 없는 변수 or 함수선언의 문제가 발생

