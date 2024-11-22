import { Resolver, Query, Args, Mutation, Field, ObjectType } from '@nestjs/graphql';
import { TelemetryQuery } from './telemetry.resolver';
import { JwtAuthenticationGuard } from 'src/modules/user/guards/jwt-authentication/jwt-authentication.guard';
import { UseGuards } from '@nestjs/common';
import { AdminGuard } from 'src/modules/user/guards/admin/admin.guard';
import { FailTelemetryService } from '../services/fail-telemetry/fail-telemetry.service';
import { CreateFailTelemetryDto } from '../dto/create-fail-telemetry.dto';


@ObjectType()
export class FailTelemetryQuery extends TelemetryQuery {

  @Field()
  code: string;

  @Field()
  message: string;
}


@Resolver(() => FailTelemetryQuery)
export class FailTelemetryResolver {
  constructor(
    private readonly failTelemetryService: FailTelemetryService,
  ) {}

  @Query(() => [FailTelemetryQuery])
  @UseGuards(AdminGuard)
  async failTelemetries() {
    return this.failTelemetryService.findAll();
  }

  @Mutation(() => FailTelemetryQuery)
  @UseGuards(JwtAuthenticationGuard)
  async createFailTelemetry(
    @Args() input: CreateFailTelemetryDto,
  ) {
    return this.failTelemetryService.create(input);
  }
}

