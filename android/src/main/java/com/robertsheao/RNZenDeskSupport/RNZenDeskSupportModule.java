/**
 * Created by Patrick O'Connor on 8/30/17.
 * https://github.com/RobertSheaO/react-native-zendesk-support
 */

package com.robertsheao.RNZenDeskSupport;

import android.content.Intent;
import android.app.Activity;
import android.os.Build;
import android.util.Log;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.Callback;
import com.facebook.react.bridge.NativeModule;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.WritableArray;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.bridge.WritableNativeArray;
import com.facebook.react.bridge.WritableNativeMap;
import com.zendesk.service.ErrorResponse;
import com.zendesk.service.ZendeskCallback;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import zendesk.commonui.UiConfig;
import zendesk.core.AnonymousIdentity;
import zendesk.core.Zendesk;
import zendesk.support.Article;
import zendesk.support.ArticleItem;
import zendesk.support.Category;
import zendesk.support.CustomField;
import zendesk.support.HelpCenterProvider;
import zendesk.support.Section;
import zendesk.support.Support;
import zendesk.support.guide.ViewArticleActivity;
import zendesk.support.request.RequestActivity;
import zendesk.support.requestlist.RequestListActivity;
import zendesk.support.guide.HelpCenterActivity;

public class RNZenDeskSupportModule extends ReactContextBaseJavaModule {

  HelpCenterProvider provider;

  public RNZenDeskSupportModule(ReactApplicationContext reactContext) {
    super(reactContext);
  }

  @Override
  public String getName() {
    return "RNZenDeskSupport";
  }

  private static long[] toLongArray(ArrayList<?> values) {
    long[] arr = new long[values.size()];
    for (int i = 0; i < values.size(); i++)
      arr[i] = Long.parseLong((String) values.get(i));
    return arr;
  }

  @ReactMethod
  public void initialize(ReadableMap config) {
    String appId = config.getString("appId");
    String zendeskUrl = config.getString("zendeskUrl");
    String clientId = config.getString("clientId");
    Zendesk.INSTANCE.init(getReactApplicationContext(), zendeskUrl, appId, clientId);
    Support.INSTANCE.init(Zendesk.INSTANCE);

  }

  @ReactMethod
  public void setupIdentity(ReadableMap identity) {
    AnonymousIdentity.Builder builder = new AnonymousIdentity.Builder();

    if (identity != null && identity.hasKey("customerEmail")) {
      builder.withEmailIdentifier(identity.getString("customerEmail"));
    }

    if (identity != null && identity.hasKey("customerName")) {
      builder.withNameIdentifier(identity.getString("customerName"));
    }

    Zendesk.INSTANCE.setIdentity(builder.build());
  }

  @ReactMethod
  public void showHelpCenterWithOptions(ReadableMap options) {
    HelpCenterActivityBuilder.create()
            .withOptions(options)
            .show(getReactApplicationContext());
  }

  @ReactMethod
  public void showCategoriesWithOptions(ReadableArray categoryIds, ReadableMap options) {
    HelpCenterActivityBuilder.create()
            .withOptions(options)
            .withArticlesForCategoryIds(categoryIds)
            .show(getReactApplicationContext());
  }

  @ReactMethod
  public void showSectionsWithOptions(ReadableArray sectionIds, ReadableMap options) {
    List<Long> sections = new ArrayList<>();

    // Iterate through the array
    for (Long section: toLongArray(sectionIds.toArrayList())) {
      // Add each element into the list
      sections.add(section);
    }

    HelpCenterActivity.builder()
            .withArticlesForSectionIds(sections)
            .show(getReactApplicationContext());
  }

  @ReactMethod
  public void showLabelsWithOptions(ReadableArray labels, ReadableMap options) {
    HelpCenterActivityBuilder.create()
            .withOptions(options)
            .withLabelNames(labels)
            .show(getReactApplicationContext());
  }

  @ReactMethod
  public void showHelpCenter() {
    showHelpCenterWithOptions(null);
  }

  @ReactMethod
  public void showCategories(ReadableArray categoryIds) {
    showCategoriesWithOptions(categoryIds, null);
  }

  @ReactMethod
  public void showSection(String article) {
    Long articleID = Long.valueOf(article);
    ViewArticleActivity.builder(articleID)
            .show(getReactApplicationContext());
  }

  @ReactMethod
  public void showSections(ReadableArray sectionIds) {
    showSectionsWithOptions(sectionIds, null);
  }

  @ReactMethod
  public void showLabels(ReadableArray labels) {
    showLabelsWithOptions(labels, null);
  }

  @ReactMethod
  public void callSupport(ReadableMap customFields) {
    Activity activity = getCurrentActivity();

    if(activity != null){
      RequestActivity.builder()
              .withTags("mobile", Build.BRAND, String.valueOf(Build.VERSION.SDK_INT), Build.MODEL, "Android")
              .show(getReactApplicationContext());
    }
  }

  @ReactMethod
  public void supportHistory() {

    Activity activity = getCurrentActivity();

    UiConfig requestActivityConfig = RequestActivity.builder()
            .withTags("mobile", Build.BRAND, "API" + String.valueOf(Build.VERSION.SDK_INT), Build.MODEL, "Android")
            .config();

    RequestListActivity.builder()
            .show(getReactApplicationContext(), requestActivityConfig);
  }

  // PROVIDER METHODS

  @ReactMethod
  public void createProvider() {
    Log.i("CATEGORYB", "CREATEBOI");
    provider = Support.INSTANCE.provider().helpCenterProvider();
  }

  @ReactMethod
  public void getSection(String section, final Callback returnArticles) {
    provider.getArticles(Long.valueOf(section), new ZendeskCallback<List<Article>>() {
      @Override
      public void onSuccess(List<Article> section) {

        WritableArray sectionData = Arguments.createArray();

        for (Article article: section) {
          WritableArray articleInfo = new WritableNativeArray();
          articleInfo.pushString(article.getTitle());
          articleInfo.pushString(article.getId().toString());
          sectionData.pushArray(articleInfo);
        }
        WritableArray error = new WritableNativeArray();
        error.pushNull();
        returnArticles.invoke(error, sectionData);
      }

      @Override
      public void onError(ErrorResponse errorResponse) {
        returnArticles.invoke();
      }
    });
  }

  @ReactMethod
  public void getCategory(String categoryID, final Callback returnArticles) {
    provider.getSections(Long.valueOf(categoryID), new ZendeskCallback<List<Section>>() {
      @Override
      public void onSuccess(List<Section> sections) {
        WritableArray sectionData = Arguments.createArray();

        for(Section section: sections){
          WritableArray sectionNameAndID = new WritableNativeArray();
          sectionNameAndID.pushString(section.getName());
          sectionNameAndID.pushString(section.getId().toString());
          sectionData.pushArray(sectionNameAndID);
        }
        WritableArray error = new WritableNativeArray();
        error.pushNull();
        returnArticles.invoke(error, sectionData);
      }

      @Override
      public void onError(ErrorResponse errorResponse) {
      }
    });
  }

  @ReactMethod
  public void getArticle(String article, final Callback returnArticle) {
    provider.getArticle(Long.valueOf(article), new ZendeskCallback<Article>() {
      @Override
      public void onSuccess(Article article) {

        WritableArray articleInfo = new WritableNativeArray();
        articleInfo.pushString(article.getTitle());
        articleInfo.pushString(article.getBody());
        articleInfo.pushString(article.getAuthor().toString());
        articleInfo.pushString(article.getCreatedAt().toString());
        WritableArray error = new WritableNativeArray();
        error.pushNull();
        returnArticle.invoke(error, articleInfo);
      }

      @Override
      public void onError(ErrorResponse errorResponse) {
        returnArticle.invoke();
      }
    });
  }

}
