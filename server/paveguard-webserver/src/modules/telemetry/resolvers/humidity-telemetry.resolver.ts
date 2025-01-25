import { Resolver, Query, Args, Mutation, Field, ObjectType } from '@nestjs/graphql';
import { CreateHumidityTelemetryDto } from '../dto/create-humidity-telemetry.dto';
import { HumidityTelemetryService } from '../services/humidity-telemetry/humidity-telemetry.service';
import { TelemetryQuery } from './telemetry.resolver';
import { JwtAuthenticationGuard } from 'src/modules/user/guards/jwt-authentication/jwt-authentication.guard';
import { UseGuards } from '@nestjs/common';
import { AdminGuard } from 'src/modules/user/guards/admin/admin.guard';
import { TelemetryFilters } from '../dto/create-telemetry.dto';


@ObjectType()
export class HumidityTelemetryQuery extends TelemetryQuery {

  @Field()
  humidity: number;
}

@Resolver(() => HumidityTelemetryQuery)
export class HumidityTelemetryResolver {
  constructor(
    private readonly humidityTelemetryService: HumidityTelemetryService
  ) {}

  @Query(() => [HumidityTelemetryQuery])
  @UseGuards(AdminGuard)
  async humidityTelemetries(
    @Args({ nullable: true }) filters?: TelemetryFilters,
  ) {
    return this.humidityTelemetryService.findAll(filters);
  }

  @Mutation(() => HumidityTelemetryQuery)
  async createHumidityTelemetry(
    @Args() input: CreateHumidityTelemetryDto,
  ) {
    return this.humidityTelemetryService.create(input);
  }
}

